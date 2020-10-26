function [data, n_data] = ilm_read_ser(path_fn, iz_0, iz_e)   
    if(nargin<2)
        iz_0 = 1;
    end
    
    info = ilm_read_info_ser(path_fn);

    if(nargin<3)
        iz_e = info.nz;
    end
    
    iz_0 = ilm_set_bound(iz_0, 1, info.nz);
    iz_e = ilm_set_bound(iz_e, iz_0, info.nz);
    nz = min(info.nz, iz_e-iz_0+1);
    data_offset_bytes = info.data_offset_bytes + (iz_0-1)*(info.nxy*ilm_sizeof(info.dtype)+info.data_skip_bytes);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fid = fopen(path_fn, 'rb');
    fseek(fid, data_offset_bytes, -1);
    str_exec = [num2str(info.nxy), '*', info.dtype, '=>', info.dtype];
    data = fread(fid, [info.nxy, nz], str_exec, info.data_skip_bytes);
    fclose(fid);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    data = reshape(data, info.ny, info.nx, []);
    data = permute(data, [2, 1, 3]);
    data = flipud(data);
    
    if(nargout>1)
        n_data = info.nz;
    end
end
