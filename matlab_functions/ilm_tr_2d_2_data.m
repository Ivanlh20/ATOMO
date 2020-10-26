function[data_o] = ilm_tr_2d_2_data(system_conf, data, txy, mw, bg_opt, bg)
    dx = 1; 
    dy = 1;
    data_o = data;
    
    n_data = ilm_nz_data(data);
    
    if(nargin<6)
        bg = 0;
    end
        
    if(nargin<5)
        bg_opt = 1;
    end
    
    if(nargin<4)
        mw = 1;
    end
    
    if(size(txy, 1)==1)
        txy = repmat(txy, n_data, 1);
    end
    
    if(size(bg, 1)==1)
        bg = repmat(bg, n_data, 1);
    end 
    
    if(isstruct(data))
        for ik=1:n_data
            im = double(data_o(ik).image);
            im = ilc_tr_2d(system_conf, im, dx, dy, txy(ik, :), bg_opt, bg(ik)).*mw;
            data_o(ik).image = im;
        end
    else
        for ik=1:n_data
            im = double(squeeze(data_o(:, :, ik)));
            im = ilc_tr_2d(system_conf, im, dx, dy, txy(ik, :), bg_opt, bg(ik)).*mw;
            data_o(:, :, ik) = im;
        end    
    end
end