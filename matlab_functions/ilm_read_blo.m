% Read blo file
function [data, info] = ilm_read_blo(path_fn)
    % Ivan Lobato, Ivanlh20@gmail.com 
    % April 2018
    % This code was written using the reverse engineered

    info = ilm_read_info_blo(path_fn);
    
    nx = info.DP_SZ;
    ny = nx;
    nxy = nx*ny;
    nxy_gr = info.NX*info.NY;
    
    fid = fopen(path_fn, 'r');
    fseek(fid, info.Data_offset_2 + 6, 0);
    str_exec = [num2str(nxy), '*', info.dtype, '=>', info.dtype];
    data = fread(fid, [nxy, nxy_gr], str_exec, 6);
    fclose(fid);
    
    data = reshape(data, [nx ny info.NX info.NY]);
    data = permute(data, [2, 1, 4, 3]);
    
%     if(~strcmpi(strtrim(type_out), ''))
%         data = eval([type_out, '(data)']);
%     end
end