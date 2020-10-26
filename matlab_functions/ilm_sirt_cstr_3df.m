function[cube]=ilm_sirt_cstr_3df(data, angles, n_iter, n_iter_sirt, bb_show, f_thr, rec_sel, g_max)
    n_xyz_0 = 512;
    
    if(nargin<6)
       f_thr = 0.5;
    end
    
    if(nargin<5)
       bb_show = false;
    end
    
    if(nargin<4)
        n_iter_sirt = 50;
    end
    
    if(nargin<3)
        n_iter = 5;
    end

    [nz, nx, n_data] = ilm_size_data(data);
    ny = nx;
    
    if(nargin<7)
       rec_sel = [];
    end
    
    if(nargin<8)
       g_max = min([nx, ny, nz]/2-1);
    end
    
    radius_max = [nx, ny, nz]/2;
    if(isempty(rec_sel))
        radius_cyl = 0.95*radius_max(1);
        f_bw_z = 0.97;
    else
        radius_cyl = abs(diff(rec_sel(:, 1)))/2;
        f_bw_z = min(0.97, abs(diff(rec_sel(:, 2)))/nz);
    end
    radius_bw = round(0.5*radius_cyl + 0.5*radius_max(1));
    
    if(nx>nz)
        radius_g_ept = g_max*[1, 1, nz/nx];
    else
        radius_g_ept = g_max*[nx/nz, nx/nz, 1];
    end
    
    f_bw = [repmat(radius_bw/radius_max(1), 1, 2), f_bw_z];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    st_data.g_max = g_max;
    st_data.nx = nx;
    st_data.ny = ny;
    st_data.nz = nz;
    st_data.n_data = n_data;
    st_data.n_iter_f = n_iter_sirt;
    st_data.angles = angles*pi/180;
    
    st_data.mask_g_ept = ilm_ellipsoid_butterworth(st_data.nx, st_data.ny, st_data.nz, radius_g_ept, 32);
    st_data.mask_g_ept = ifftshift(st_data.mask_g_ept);
%     
%     st_data.mask_cyl = single(ilm_cylindrical_mask(st_data.nx, st_data.ny, st_data.nz, radius_cyl, 1));

    st_data.data = single(data);
    st_data.n_iter_f = n_iter_sirt;
    sc_factor = sum(reshape(st_data.data(:, :, 1), [], 1));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    radius_p = round(f_bw.*[st_data.nx, st_data.ny, st_data.nz]/2);
    f_x = ilc_func_butterworth(nx, 1, 1, 1, radius_p(1), 32, 0);
    f_y = ilc_func_butterworth(1, ny, 1, 1, radius_p(2), 32, 0);
    f_z = ilc_func_butterworth(nz, 1, 1, 1, radius_p(3), 32, 0);

    fxy_bw = ilc_func_butterworth(nx, ny, 1, 1, radius_cyl, 32, 0, [0, 0, 0, 0], [st_data.nx, st_data.ny]/2 - 0.5); 

    fxy_bw = single(fxy_bw.*f_x.*f_y);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cube = single(0);
    n = 0.5;
    for it=1:n_iter
        tic;
        cube = ilm_sirt_3df_patch(st_data, cube, false, n_xyz_0);
        toc;
        
        % apply masks
        for iz=1:st_data.nz
            cube(:, :, iz) = f_z(iz)*fxy_bw.*cube(:, :, iz);
        end

        tic;
        cube = ilm_apply_fs_3d_thr(cube, n, st_data.mask_g_ept, bb_show); 
        toc;

        tic;
        cube = ilm_apply_rs_3d_thr(cube, f_thr, bb_show);
        toc;
%         
%         if(it<=2)
%             cube = sqrt(cube);
%         end
%         
        cube = cube*sc_factor/sum(cube(:));

%         ilm_write_tif(cube, ['iter_',num2str(it), '.tif'], 'uint8', true);
        disp(it)
        if(bb_show)
            pause(0.25);
        end
    end

    st_data.n_iter_f = max(200, 4*n_iter_sirt);
    
    tic;
    cube = ilm_sirt_3df_patch(st_data, cube, false);
%     ilm_write_tif(cube, 'iter_e.tif', 'uint16', true);
    
%     % apply masks
%     for iz=1:st_data.nz
%         cube(:, :, iz) = f_z(iz)*fxy_bw.*cube(:, :, iz);
%     end
%     fcube = fftn(cube).*st_data.mask_g_ept;
%     cube = max(0, real(ifftn(fcube)));
    cube = ilm_apply_rs_3d_thr(cube, f_thr);
%     apply masks
    for iz=1:st_data.nz
        cube(:, :, iz) = f_z(iz)*fxy_bw.*cube(:, :, iz);
    end
    fcube = fftn(cube).*st_data.mask_g_ept;
    cube = max(0, real(ifftn(fcube)));
    cube = cube*sc_factor/sum(cube(:));
    toc;
end
