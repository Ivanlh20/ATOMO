function [info] = ilm_read_info_mib(path_fn)
%     Copyright 2019 Ivan Lobato <Ivanlh20@gmail.com>
%     you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version of the License, or
%     (at your option) any later version.
%     This code is distributed in the hope that it will be useful, 
%     but WITHOUT ANY WARRANTY;without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%     GNU General Public License for more details.

    fid = fopen(path_fn, 'r');  %Set file ID for read only
    data_header = fread(fid, 100, 'uint8=>char');           %Read file first 100 characters to get info from file
    fseek(fid, 0, 1); 
    info.file_size = ftell(fid);
    fclose(fid);

    info.header_size_b = str2double(data_header(12:16)');    %Size of header
    info.dtype = data_header(31:33)';                        %Get data type
    info.nx = str2double(data_header(21:24)');               %Image size x
    info.ny = str2double(data_header(26:29)');               %Image size y
    info.nxy = info.nx*info.ny;
    
    if(strcmpi(info.dtype, 'U08'))
        info.dtype = 'U8';
    elseif(strcmpi(info.dtype, 'U01'))
        info.dtype = 'U1';
    end

    switch info.dtype        %Depending on dtype value, select the good reading format for the file data
        case 'U32'          
            info.dtype = 'uint32';
            info.header_size = info.header_size_b/4; %As headers are characters of 8 bit depth, they need to be choped
            info.dtype_size = 4; %KMC byte size
        case 'U16'
            info.dtype = 'uint16';
            info.header_size = info.header_size_b/2; %As headers are characters of 8 bit depth, they need to be choped
            info.dtype_size = 2; %KMC byte size
        case 'U8'
            info.dtype = 'uint8';
            info.header_size = info.header_size_b*1;   %As headers are characters of 8 bit depth, no need to chop here
            info.dtype_size = 1; %KMC byte size
        case 'U1'
            info.dtype = 'ubit1';
            info.header_size = info.header_size_b*8;  %As headers are characters of 8 bit depth, it has to be extended
            info.dtype_size = 1;
    end
    info.nxy_b = info.nxy*info.dtype_size;
    info.nz = info.file_size/(info.nxy_b + info.header_size_b);
end