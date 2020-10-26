function [ny, nx, nz] = ilm_size_mib(path_fn)
    info = ilm_read_info_mib(path_fn);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nx = info.nx;
    ny = info.ny;
    if(nargout>2)
        nz = info.nz;
    end
end