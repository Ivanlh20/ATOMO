% Read mrc file
function [data] = ilm_read_mrc(path_fn, type_out)
    if(nargin<2)
        type_out = 'double';
    end
    
    [fid, ~] = fopen(path_fn, 'r');
    data = [];
    if fid == -1
        error('can''t open file');
        return; %#ok<UNRCH>
    end
    
    nx = fread(fid,1, 'long');
    ny = fread(fid,1, 'long');
    nz = fread(fid,1, 'long');
    type = fread(fid,1, 'long');
%     fprintf(1, 'nx= %d ny= %d nz= %d type= %d', nx, ny,nz,type);

    % find header size
    fseek(fid, 92, -1);
    header_size = fread(fid, 1, 'int32');
    
    % jump to the starting point of the data    
    fseek(fid, 1024+header_size, -1);
    
    % Shorts
    if(type==1)
        data = fread(fid, nx*ny*nz, 'int16');
    elseif(type==2)
        data = fread(fid, nx*ny*nz, 'float32');
    end
    fclose( fid);

    if(nz==1)
        data = reshape(data, [nx ny]);
    else
        data = reshape(data, [nx ny nz]);
    end
    
    data = eval([type_out, '(data)']);
end