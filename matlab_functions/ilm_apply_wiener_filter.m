function[im_w] = ilm_apply_wiener_filter(im_n, im_r, g_max, bd_p, n_it)
    [ny_i, nx_i] = size(im_n); 
    
    if(nargin<5)
        n_it = 1;
    end
        
    if(nargin<4)
        bd_p = [0, 0];
    end
    
    im_n = double(im_n);
    im_r = double(im_r);
    if((bd_p(1)>0.5)||(bd_p(2)>0.5))
        ax = (bd_p(1)+1):(bd_p(1)+nx_i);
        ay = (bd_p(2)+1):(bd_p(2)+ny_i);

        nx = round(nx_i+2*bd_p(1));
        ny = round(ny_i+2*bd_p(2));
        im_r = ilc_add_bd_pbc(im_r, bd_p);
        im_n = ilc_add_bd_pbc(im_n, bd_p);
        
        fw_x = ilc_func_butterworth(nx, 1, 1, 1, nx_i/2, 16, 0, [0, 0, 0, 0]);
        fw_y = ilc_func_butterworth(1, ny, 1, 1, ny_i/2, 16, 0, [0, 0, 0, 0]);        
        FBW = fw_x.*fw_y;
        
        bg = min(im_r(:));
        im_r = (im_r-bg).*FBW + bg;
        im_n = (im_n-bg).*FBW + bg;
    else
        nx = nx_i;
        ny = ny_i;        
        ax = 1:nx;
        ay = 1:ny;        
    end
    
    if(nargin<3)
        g_max = min([nx, ny]/2)-1;
    else
        g_max = min(g_max, min([nx, ny]/2)); 
    end  
    
    FBW = ilc_func_butterworth(nx, ny, 1, 1, g_max, 8, 1, [0, 0, 0, 0]);
    im_r = real(fftshift(ifft2(FBW.*fft2(ifftshift(im_r)))));
        
    b_pos = min(im_n(:))>0;
    fim_n = fft2(ifftshift(im_n));    
    for it=1:n_it
        fim_r = fft2(ifftshift(im_r));
        S = abs(fim_r).^2;
        N = abs(fim_n-fim_r).^2;
        H = FBW.*S./(S+N);
%         ilm_imagesc(1, fftshift(F./(F+N)).^0.125)        
        im_r = real(fftshift(ifft2(H.*fim_n)));
        if(b_pos)
            im_r = max(0, im_r); 
        end
    end
    im_w = im_r(ay, ax);
    
%     im_w = (im_w-mean(im_w(:)))/std(im_w(:));
%     im_w = im_w*im_std + im_mean;   
end