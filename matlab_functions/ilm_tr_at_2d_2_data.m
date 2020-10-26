function[data_o] = ilm_tr_at_2d_2_data(system_conf, data, A, txy, mw, bg_opt, bg)
    dx = 1; 
    dy = 1;
    data_o = data;
    
    n_data = ilm_nz_data(data);
    
    if(nargin<7)
        bg = 0;
    end
        
    if(nargin<6)
        bg_opt = 1;
    end
    
    if(nargin<5)
        mw = 1;
    end
    
    if(nargin<4)
        txy = [0, 0];
    end
    
    if(nargin<3)
        A = [1, 0; 0, 1];
    end
    
    if(size(bg, 1)==1)
        bg = repmat(bg, n_data, 1);
    end

    if(size(txy, 1)==1)
        txy = repmat(txy, n_data, 1);
    end
    
    if(isstruct(data))
        for ik=1:n_data
            im = double(data_o(ik).image); 
            im = ilc_tr_at_2d(system_conf, im, dx, dy, A, txy(ik, :), bg_opt, bg(ik)); 
            im = im.*mw;
            data_o(ik).image = im;
        end
    else
        for ik=1:n_data
            im = double(data_o(:, :, ik));
            im = ilc_tr_at_2d(system_conf, im, dx, dy, A, txy(ik, :), bg_opt, bg(ik));
            im = im.*mw;
            data_o(:, :, ik) = im;   
        end        
    end
end