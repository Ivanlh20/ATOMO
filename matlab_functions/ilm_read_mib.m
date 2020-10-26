function [data, n_data] = ilm_read_mib(path_fn, bb_rs)
%     Copyright 2019 Ivan Lobato <Ivanlh20@gmail.com>
%     you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version of the License, or
%     (at your option) any later version.
%     This code is distributed in the hope that it will be useful, 
%     but WITHOUT ANY WARRANTY;without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%     GNU General Public License for more details.

    if(nargin<2)
        bb_rs = true;
    end
    
    info = ilm_read_info_mib(path_fn);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fid = fopen(path_fn, 'r');
    fseek(fid, info.header_size_b, 0);
    str_exec = [num2str(info.nxy), '*', info.dtype, '=>', info.dtype];
    data = fread(fid, [info.nxy, info.nz], str_exec, info.header_size_b);
    fclose(fid);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if(bb_rs)
        data = reshape(data, info.ny, info.nx, []);
    end
    
    if(nargout>1)
        n_data = info.nz;
    end
end
