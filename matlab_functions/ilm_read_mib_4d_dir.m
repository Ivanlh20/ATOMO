function [data] = ilm_read_mib_4d_dir(path_dir, nx_d)
%     Copyright 2019 Ivan Lobato <Ivanlh20@gmail.com>
%     you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version of the License, or
%     (at your option) any later version.
%     This code is distributed in the hope that it will be useful, 
%     but WITHOUT ANY WARRANTY;without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%     GNU General Public License for more details.

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    files = ilm_dir(path_dir, '*.mib');
    n_files = size(files, 1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    info = ilm_read_info_mib(files{1});
    if(nargin<2)
        nx_d = info.nz;
    end  
    data = zeros(info.ny, info.nx, n_files*max(nx_d, info.nz), info.dtype);
        
    nxy_d = 0;
    iz_0 = 1;
    for ifiles=1:n_files
        [im_line, n_z] = ilm_read_mib(files{ifiles});
        nxy_d = nxy_d + n_z;
        iz_e = iz_0 + n_z-1;
        data(:, :, iz_0:iz_e) = im_line;
        iz_0 = iz_e+1;
        
%         ilm_imagesc(1, im_line(:, :, 25));
        
        pp = 100*ifiles/n_files;
        disp(['Reading percentage = ', num2str(pp, '%5.2f'), '%.'])
    end
    ny_d = nxy_d/nx_d;
    data = reshape(data(:, :, 1:nxy_d), info.ny, info.nx, nx_d, ny_d);
    data = permute(data, [1, 2, 4, 3]);
end