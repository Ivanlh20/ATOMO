function[im]=ilm_sinc_2d_interpolation(im_i, n, bd_p)
    if(nargin<3)
        bd_p = [0, 0];
    end
    
    [ny_i, nx_i] = size(im_i);
    bd_p(1) = ilm_pn_border(ny_i, bd_p(1));
    bd_p(2) = ilm_pn_border(ny_i, bd_p(2));
    
    if(bd_p>0.5)
        ax = (bd_p(1)*n+1):((bd_p(1)+nx_i)*n);
        ay = (bd_p(2)*n+1):((bd_p(2)+ny_i)*n);
        
        im_i = ilm_damp_added_borders(im_i, bd_p, 1, 0);

        [ny_i, nx_i] = size(im_i);
        nx = nx_i*n;
        ny = ny_i*n;
    else  
        [ny_i, nx_i] = size(im_i);
        nx = nx_i*n;
        ny = ny_i*n;
        
        ax = 1:nx;
        ay = 1:ny;         
    end
    
    ix_0 = (nx-nx_i)/2+1;
    ix_e = ix_0 + nx_i-1;
    iy_0 = (ny-ny_i)/2+1;
    iy_e = iy_0 + ny_i-1;
    fim = zeros(ny, nx);
    fim(iy_0:iy_e, ix_0:ix_e) = fftshift(fft2(ifftshift(im_i)));

%     figure(1); clf;
%     imagesc(abs(fim).^0.25);
%     axis image; 
%     colormap jet;

    im = real(fftshift(ifft2(ifftshift(fim))))*n^2;
    im = im(ay, ax);

    figure(1); clf;
    imagesc(min(max(0, im), 1));
    axis image off; 
    colormap gray;
end