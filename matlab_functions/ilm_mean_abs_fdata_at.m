function [image_av] = ilm_mean_abs_fdata_at(system_conf, data, at_p)
    b_st = isstruct(data);
    [ny, nx, n_data] = ilm_size_data(data);
    
    dx = 1; 
    dy = 1;
    
    if(nargin<3)
        at_p = ilm_dflt_at_p(n_data);
    end
    bg_opt = 3;
    
    image_av = zeros(ny, nx);
    radius = 0.95*min(nx, ny)/2;
    fbw = ilc_func_butterworth(nx, ny, 1, 1, radius, 8);
    for ik = 1:n_data
        [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(ik, :));
        image_ik = ilm_extract_data(data, ik, b_st, 'double');
        [image_ik, bg] = ilc_tr_at_2d(system_conf, image_ik, dx, dy, A, txy, bg_opt, 0);
        image_ik = (image_ik-bg).*fbw;
        
        image_av = image_av + abs(fft2(image_ik));
    end
    
    image_av = ifftshift(image_av/n_data);
end