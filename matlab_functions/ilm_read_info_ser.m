function [info] = ilm_read_info_ser(path_fn)
    fid = fopen(path_fn, 'rb');  %Set file ID for read only
    
    % Read in the header information
    % [byteOrder, seriesID, seriesVersion, dataTypeID, tagTypeID,
    % totalNumberElements, validNumberElements, offsetArrayOffset]
    
    byteOrder = fread(fid, 1, 'int16'); %dec2hex(byteOrder) should be 4949
    seriesID = fread(fid, 1, 'int16');
    seriesVersion = fread(fid, 1, 'int16');
    dataTypeID = fread(fid, 1, 'int32'); %0x4120 = 1D arrays; 0x4122 = 2D arrays
    tagTypeID = fread(fid, 1, 'int32'); %0x4152 = Tag is time only; 0x4142 = Tag is 2D with time

    totalNumberElements = fread(fid, 1, 'int32'); %the number of data elements in the original data set
    validNumberElements = fread(fid, 1, 'int32'); %the number of data elements written to the file
    offsetArrayOffset = fread(fid, 1, 'int32'); %the offset (in bytes) to the beginning of the data offset array

    numberDimensions = fread(fid, 1, 'int32'); %the number of dimensions of the indices (not the data)
    %Dimension arrays (starts at byte offset 30)
    for ij = 1:numberDimensions
        dimensionSize = fread(fid, 1, 'int32'); %the number of elements in this dimension
        calibrationOffset = fread(fid, 1, 'float64'); %calibration value at element calibrationElement
        calibrationDelta = fread(fid, 1, 'float64'); %calibration delta between elements of the series
        calibrationElement = fread(fid, 1, 'int32'); %the element in the series with a calibraion value of calibrationOffset
        descriptionLength = fread(fid, 1, 'int32'); %length of the description string
        description = fread(fid, descriptionLength, '*char')'; %describes the dimension
        unitsLength = fread(fid, 1, 'int32'); %length of the units string
        units = fread(fid, unitsLength, '*char'); %name of the units in this dimension
    end

    %Get arrays containing byte offsets for data and tags
    fseek(fid, offsetArrayOffset, -1); %seek in the file to the offset arrays
    %Data offset array (the byte offsets of the individual data elements)
    
    %strbits = ilm_ifelse(bits==32, 'int32', 'int64'); Ivan Lobato
    strbits = ilm_ifelse(seriesVersion==528, 'int32', 'int64');
    
    %change dataOffsetArray and tagOffsetArray from int32 to int64 Ivan Lobato
    dataOffsetArray = fread(fid, totalNumberElements, strbits);
    
    if dataTypeID == hex2dec('4120') %Get data from 1D elements
        fseek(fid, dataOffsetArray(1),-1);
        calibrationOffset = fread(fid, 1, 'float64'); %calibration value at element calibrationElement
        calibrationDelta = fread(fid, 1, 'float64'); %calibration delta between elements of the array
        calibrationElement = fread(fid, 1, 'int32'); %element in the array with calibration value of calibrationOffset
        
        info.dtype = getType(fread(fid, 1, 'int16'));
        info.nx = 1;
        info.ny = fread(fid, 1, 'int32'); %number of elements in the array

        info.nxy = info.nx*info.ny;
        info.nz = validNumberElements;
        info.data_offset_bytes = dataOffsetArray(1) + 26;
        if(info.nz==1)
            info.data_skip_bytes = 0;
        else
            data_type_b = ilm_sizeof(info.dtype);
            info.data_skip_bytes = dataOffsetArray(2) - dataOffsetArray(1)-info.nxy*data_type_b;
        end
        
    elseif dataTypeID == hex2dec('4122') %Get data from 2D elements
        fseek(fid, dataOffsetArray(1),-1);
                
        calibrationOffsetX = fread(fid, 1, 'float64'); %calibration at element calibrationElement along x
        calibrationDeltaX = fread(fid, 1, 'float64');
        calibrationElementX = fread(fid, 1, 'int32'); %element in the array along x with calibration value of calibrationOffset
        calibrationOffsetY = fread(fid, 1, 'float64');
        calibrationDeltaY = fread(fid, 1, 'float64');
        calibrationElementY = fread(fid, 1, 'int32');

        info.dtype = getType(fread(fid, 1, 'int16'));
        info.nx = fread(fid,  1, 'int32');
        info.ny = fread(fid,  1, 'int32');
        info.nxy = info.nx*info.ny;
        info.nz = validNumberElements;
        info.data_offset_bytes = dataOffsetArray(1) + 50;
        if(info.nz==1)
            info.data_skip_bytes = 0;
        else
            data_type_b = ilm_sizeof(info.dtype);
            info.data_skip_bytes = dataOffsetArray(2) - dataOffsetArray(1)-info.nxy*data_type_b;
        end
    end
    
    fseek(fid, 0, 1); 
    info.file_size = ftell(fid);
    
    fclose(fid);
end

function [data_type] = getType(data_type_n)
    switch data_type_n
        case 1
            data_type = 'uint8';
        case 2
            data_type = 'uint16';
        case 3
            data_type = 'uint32';
        case 4
            data_type = 'int8';
        case 5
            data_type = 'int16';
        case 6
            data_type = 'int32';
        case 7
            data_type = 'float32';
        case 8
            data_type = 'float64';
        otherwise
            error('Unsupported data type') %complex data types are unsupported currently
    end
end