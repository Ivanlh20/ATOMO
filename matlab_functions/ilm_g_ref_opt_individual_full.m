function[xyz, mask_g]=ilm_g_ref_opt_individual_full(xyz, d_min, cube_fft_fit, path_dir, bb_show, bb_mask_save)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    par = ilm_g_ref_opt_set_par_0(xyz, d_min, cube_fft_fit);

    if(bb_mask_save)
        data = par.data;
        par.data(:, 4) = 1;
        par.data(2:end, 5) = 2.0;
        mask_g = ilm_g_ref_create_mask_gaussian_3d(par);
        par.data = data;
        ilm_write_tif(mask_g, [path_dir, 'mask_g_bf.tif'], 'uint8', true);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    par = ilm_g_ref_opt_iso_A_sigma_3d(par, cube_fft_fit, 50, bb_show);
    par.data(2:end, 5) = min(par.data(1, 5)/2, mean(par.data(2:end, 5)));
    par.data(:, 6) = min(par.d_max, 3.0*par.data(:, 5));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    par = ilm_g_ref_opt_iso_sigma_3d(par, cube_fft_fit, 50, bb_show);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    par = ilm_g_ref_opt_iso_A_3d(par, cube_fft_fit, 50, bb_show);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for it=1:2
        par = ilm_g_ref_opt_iso_sigma_3d(par, cube_fft_fit, 50, bb_show);
        par = ilm_g_ref_opt_iso_xyz_3d(par, cube_fft_fit, 100, bb_show);
        par = ilm_g_ref_opt_iso_A_3d(par, cube_fft_fit, 50, bb_show);
    end

    if(bb_mask_save)
        data = par.data;
        par.data(:, 4) = 1;
        par.data(2:end, 5) = 2.0;
        mask_g = ilm_g_ref_create_mask_gaussian_3d(par);
        par.data = data;
        ilm_write_tif(mask_g, [path_dir, 'mask_g_af.tif'], 'uint8', true);
    end

    if(nargout>1)
        data = par.data;
        par.data(:, 4) = 1;
        mask_g = ilm_g_ref_create_mask_gaussian_3d(par);
        par.data = data;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    xyz = par.data(:, 1:3);
end