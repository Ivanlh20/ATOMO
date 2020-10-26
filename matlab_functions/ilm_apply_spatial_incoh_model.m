function[im_o]=ilm_apply_spatial_incoh_model(coef, im_i, dR)
    [ny_i, nx_i] = size(im_i);
    
    bx = mod(nx_i, 2)==1;
    by = mod(ny_i, 2)==1;

    nx = nx_i;
    ny = ny_i;
    if(bx)
        nx = nx + 1;
        im_i = [im_i, im_i(:, end)];
    end
      
    if(by)
        ny = ny + 1;
        im_i = [im_i; im_i(end, :)];
    end
    
    lx = nx*dR(1);
    ly = ny*dR(2);
    g_max = min(nx*lx/2, nx*ly/2);
    
    [~, ~, g2] = ilm_fs_grid_2d(nx, ny, lx, ly, 1);
    fssb = coef(1)*exp(-2*pi^2*coef(2)^2*g2) + (1-coef(1))./(1+4*pi^2*coef(3)^2*g2).^(3/2);
    fssb(g2>g_max^2) = 0;
    
    im_o = real(ifft2(fft2(ifftshift(im_i)).*fssb));
    im_o = fftshift(im_o);
    if(min(im_i(:))>0)
       im_o = max(0, im_o); 
    end
    
    im_o = im_o(1:ny_i, 1:nx_i);
end