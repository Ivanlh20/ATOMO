function[data_o] = ilm_gauss_cv_2_data(system_conf, data, sigma, mw)
    dx = 1; 
    dy = 1;
    n_data = ilm_nz_data(data);
    
    if(nargin<4)
        mw = 1;
    end
    
    if(isstruct(data))
        for ik=1:n_data
            im = double(data(ik).image);
%             im = imgaussfilt(im, sigma).*mw;
            im = ilc_gauss_cv_2d(system_conf, im, dx, dy, sigma).*mw;
            data_o(ik).image = im;
        end
    else
        for ik=1:n_data
            im = double(data(:, :, ik));  
%             im = imgaussfilt(im, sigma).*mw;
            im = ilc_gauss_cv_2d(system_conf, im, dx, dy, sigma).*mw;
            if(ik==1)
                [ny, nx] = size(im);
                data_o = zeros(ny, nx, n_data);
            end
            data_o(:, :, ik) = im;
        end    
    end
end