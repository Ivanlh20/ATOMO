% Read info blo file
function [info] = ilm_read_info_blo(path_fn)
    if(nargin<1)
        path_fn = '';
    end
    
    info.ID = '';
    info.MAGIC = '';
    info.Data_offset_1 = '';     % Offset VBF
    info.Data_offset_2 = '';     % Offset DPs
    info.UNKNOWN1 = '';          % Flags for ASTAR software?
    info.DP_SZ = '';             % Pixel dim DPs
    info.DP_rotation = '';       % [degrees info( * 100 ?)]
    info.NX = '';                % Scan dim 1
    info.NY = '';                % Scan dim 2
    info.Scan_rotation = '';     % [100 * degrees]
    info.SX = '';                % Pixel size [nm]
    info.SY = '';                % Pixel size [nm]
    info.Beam_energy = '';       % [V]
    info.SDP = '';               % Pixel size [100 * ppcm]
    info.Camera_length = '';     % [10 * mm]
    info.Acquisition_time = '';  % [Serial date]
    info.Centering = '';         % [Serial date]
    info.Distortion = '';        % [Serial date]
    
    info.dtype = 'uint8';
    
    info.type = containers.Map;
    info.type('ID') = 'char';
    info.type('MAGIC') = 'uint16';
    info.type('Data_offset_1') =  'uint32';     % Offset VBF
    info.type('Data_offset_2') =  'uint32';     % Offset DPs
    info.type('UNKNOWN1') =  'uint32';          % Flags for ASTAR software?
    info.type('DP_SZ') =  'uint16';             % Pixel dim DPs
    info.type('DP_rotation') =  'uint16';       % [degrees info( * 100 ?)]
    info.type('NX') =  'uint16';                % Scan dim 1
    info.type('NY') =  'uint16';                % Scan dim 2
    info.type('Scan_rotation') =  'uint16';     % [100 * degrees]
    info.type('SX') =  'double';                % Pixel size [nm]
    info.type('SY') =  'double';                % Pixel size [nm]
    info.type('Beam_energy') =  'uint32';       % [V]
    info.type('SDP') =  'uint16';               % Pixel size [100 * ppcm]
    info.type('Camera_length') =  'uint32';     % [10 * mm]
    info.type('Acquisition_time') =  'double';  % [Serial date]
    info.type('Centering') =  'double';         % [Serial date]
    info.type('Distortion') =  'double';        % [Serial date]
    
    if(strcmpi(path_fn, ''))
        return;
    end
    
    [fid, ~] = fopen(path_fn, 'r');
    
    if fid == -1
        error('can''t open file');
        return; %#ok<UNRCH>
    end
    
    info.ID = char(fread(fid, [1, 6], info.type('ID')));
    info.MAGIC = fread(fid, 1, info.type('MAGIC'));
    info.Data_offset_1 = fread(fid, 1, info.type('Data_offset_1'));
    info.Data_offset_2 = fread(fid, 1, info.type('Data_offset_2'));
    info.UNKNOWN1 = fread(fid, 1, info.type('UNKNOWN1'));
    info.DP_SZ = fread(fid, 1, info.type('DP_SZ'));
    info.DP_rotation = fread(fid, 1, info.type('DP_rotation'));
    info.NX = fread(fid, 1, info.type('NX'));
    info.NY = fread(fid, 1, info.type('NY'));
    info.Scan_rotation = fread(fid, 1, info.type('Scan_rotation'));
    info.SX = fread(fid, 1, info.type('SX'));
    info.SY = fread(fid, 1, info.type('SY'));
    info.Beam_energy = fread(fid, 1, info.type('Beam_energy'));
    info.SDP = fread(fid, 1, info.type('SDP'));
    info.Camera_length = fread(fid, 1, info.type('Camera_length'));
    info.Acquisition_time = fread(fid, 1, info.type('Acquisition_time'));
    info.Centering = fread(fid, [1, 8], info.type('Centering'));
    info.Distortion = fread(fid, [1, 14], info.type('Distortion'));
    
    fclose(fid);
end