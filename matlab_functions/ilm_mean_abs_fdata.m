function[image_fav] = ilm_mean_abs_fdata(data, fh, bd_e)
    b_st = isstruct(data);
    [ny, nx, n_data] = ilm_size_data(data);
    
    if(nargin<3)
        bd_e = [0, 0];
    end

    if(bd_e(1)>0.5)
        nx = round(nx+2*bd_e(1));
    end
    
    if(bd_e(2)>0.5)
        ny = round(ny+2*bd_e(2));
    end
    
    if((nargin<2)||(size(fh, 1)~=ny)||(size(fh, 2)~=nx))
        radius = 0.95*min(nx, ny)/2;
        fh = ilc_func_butterworth(nx, ny, 1, 1, radius, 16);
    end
    
    bg_opt = 3;  
    image_fav = zeros(ny, nx);
    for ik = 1:n_data
        image_ik = ilm_extract_data(data, ik, b_st, 'double');
        bg = ilm_get_bg(image_ik, bg_opt, 0);
        
        image_ik = ilc_add_bd_pbc(image_ik, bd_e);
        image_ik = (image_ik-bg).*fh;
        image_fav = image_fav + abs(fft2(image_ik));
    end
    image_fav = fftshift(image_fav/n_data);
end