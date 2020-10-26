function[data] = ilm_bandwidth_limit(data, g_max, bd_p, n)
    if(nargin<4)
        n = 8;
    end
    
    if(nargin<3)
        bd_p = [0, 0];
    end
    
    if(numel(bd_p)==1)
        bd_p = repmat(bd_p, 1, 2);
    end
    
    [ny_i, nx_i, n_data] = size(data);
    bd_p = [ilm_pn_border(nx_i, bd_p(1)), ilm_pn_border(ny_i, bd_p(2))];
    
    if((bd_p(1)>0.5)||(bd_p(2)>0.5))
        ax = (bd_p(1)+1):(bd_p(1)+nx_i);
        ay = (bd_p(2)+1):(bd_p(2)+ny_i);

        nx = round(nx_i+2*bd_p(1));
        ny = round(ny_i+2*bd_p(2));
        
        f_x = ilc_func_butterworth(nx, 1, 1, 1, nx_i/2+1, 16, 0, [0, 0, 0, 0]);
        f_y = ilc_func_butterworth(1, ny, 1, 1, nx_i/2+1, 16, 0, [0, 0, 0, 0]);
        fw_xy = f_x.*f_y;       
    else
        nx = nx_i;
        ny = ny_i;        
        ax = 1:nx;
        ay = 1:ny;    
        
        fw_xy = 1;
    end
    
    f_2d = ilc_func_butterworth(nx, ny, 1, 1, g_max, n, 1, [0, 0, 0, 0]);
    for ik=1:n_data
        im_ik = ilc_add_bd_pbc(double(data(:, :, ik)), bd_p);
        bg = mean(im_ik(:));
        im_ik = (im_ik-bg).*fw_xy + bg;
        
        fim_ik = fft2(ifftshift(im_ik));
        im_ik = max(0, real(fftshift(ifft2(fim_ik.*f_2d))));   
        data(:, :, ik) = im_ik(ay, ax);
    end
end