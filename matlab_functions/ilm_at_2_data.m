function[data] = ilm_at_2_data(system_conf, data, at_p, bg_opt, bg)
    if(nargin<5)
        bg = 0;
    end
    
    if(nargin<4)
        bg_opt = 1;
    end 
    
    n_data = ilm_nz_data(data);
    dx = 1; 
    dy = 1;

    if(isstruct(data))
        for ik=1:n_data
            [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(ik, :));
            im = double(data(ik).image);
            data(ik).image = ilc_tr_at_2d(system_conf, im, dx, dy, A, txy, bg_opt, bg);
        end
    else
        for ik=1:n_data
            [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(ik, :));
            im = double(data(:, :, ik));
            data(:, :, ik) = ilc_tr_at_2d(system_conf, im, dx, dy, A, txy, bg_opt, bg);
        end        
    end
end