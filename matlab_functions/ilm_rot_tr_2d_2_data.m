function[data_o] = ilm_rot_tr_2d_2_data(system_conf, data, theta, pr, txy, mw, bg_opt, bg)
    dx = 1; 
    dy = 1;
    data_o = data;
    
    [ny, nx, n_data] = ilm_size_data(data);
    
    if(nargin<8)
        bg = 0;
    end
        
    if(nargin<7)
        bg_opt = 1;
    end
    
    if(nargin<6)
        mw = 1;
    end
    
    if(nargin<5)
        txy = [0, 0];
    end
    
    if(nargin<4)
        pr = [nx, ny]/2 + 1;
    end
    
    if(size(bg, 1)==1)
        bg = repmat(bg, n_data, 1);
    end
    
    if(size(theta, 1)==1)
        theta = repmat(theta, n_data, 1);
    end

    if(size(pr, 1)==1)
        pr = repmat(pr, n_data, 1);
    end

    if(size(txy, 1)==1)
        txy = repmat(txy, n_data, 1);
    end
    
    if(isstruct(data))
        for ik=1:n_data
            im = double(data_o(ik).image); 
            im = ilc_rot_tr_2d(system_conf, im, dx, dy, theta(ik), pr(ik, :), txy(ik, :), bg_opt, bg(ik)); 
            im = im.*mw;
            data_o(ik).image = im;
        end
    else
        for ik=1:n_data
            im = double(data_o(:, :, ik));
            im = ilc_rot_tr_2d(system_conf, im, dx, dy, theta(ik), pr(ik, :), txy(ik, :), bg_opt, bg(ik)); 
            im = im.*mw;
            data_o(:, :, ik) = im;   
        end        
    end
end