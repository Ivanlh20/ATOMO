function[image_av] = ilm_mean_data_at(system_conf, data, at_p)
    b_st = isstruct(data);
    [ny, nx, n_data] = ilm_size_data(data);
    
    dx = 1; 
    dy = 1;
    
    if(nargin<3)
        at_p = ilm_dflt_at_p(n_data);
    end
    bg_opt = 1;
    
    image_av = zeros(ny, nx);
    for ik = 1:n_data
        [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(ik, :));
        image_ik = ilm_extract_data(data, ik, b_st, 'double');
        image_av = image_av + ilc_tr_at_2d(system_conf, image_ik, dx, dy, A, txy, bg_opt, 0);
    end
    image_av = image_av/n_data;
    
%     % set constant borders
%     image_av = ilc_set_bd(image_av, 1, 1, bd);
end