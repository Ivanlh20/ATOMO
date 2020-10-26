function[v, mask_g]=ilm_g_ref_opt_vector_full(v, d_max, cube_fft_fit, path_dir, n_iter, bb_show, bb_mask_save)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    par = ilm_g_ref_opt_vector_set_par_0(v, d_max, cube_fft_fit);

    if(bb_mask_save)
        data = par.data;
        par.data(:, 4) = 1;
        par.data(2:end, 5) = 2.0;
        mask_g = ilm_g_ref_create_mask_gaussian_3d(par);
        par.data = data;
        ilm_write_tif(mask_g, size(mask_g, 3), [path_dir, 'mask_g_vector_bf.tif'], 'uint8', true);
    end
    
    par = ilm_g_ref_opt_vector_3d(par, cube_fft_fit, n_iter, bb_show);

    if(bb_mask_save)
        data = par.data;
        par.data(:, 4) = 1;
        par.data(2:end, 5) = 2.0;
        mask_g = ilm_g_ref_create_mask_gaussian_3d(par);
        par.data = data;
        ilm_write_tif(mask_g, size(mask_g, 3), [path_dir, 'mask_g_vector_af.tif'], 'uint8', true);
    end

    if(nargout>1)
        data = par.data;
        par.data(:, 4) = 1;
        par.data(2:end, 5) = 2.0;
        mask_g = ilm_g_ref_create_mask_gaussian_3d(par);
        par.data = data;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    v = par.v;
end