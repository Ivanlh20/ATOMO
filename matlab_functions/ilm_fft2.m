function[fm] = ilm_fft2(im, bd_e, n)
    if(nargin<3)
        n = 16;
    end
    [ny_i, nx_i] = size(im);
    
    bx = ilm_pn_border(nx_i, bd_e, 5);
    by = ilm_pn_border(ny_i, bd_e, 5);

    nx = round(nx_i+2*bx);
    ny = round(ny_i+2*by);    
    fw_squ_x = ilc_func_butterworth(nx, 1, 1, 1, nx_i/2+1, n, 0, [0, 0, 0, 0]);
    fw_squ_y = ilc_func_butterworth(1, ny, 1, 1, ny_i/2+1, n, 0, [0, 0, 0, 0]);
    fw_squ = fw_squ_x.*fw_squ_y; 
    bg = min(im(:));    
    im = (ilc_add_bd_pbc(im, bx, by)-bg).*fw_squ + bg;
    
%     figure(1); clf;
%     imagesc(im);
%     colormap gray;
%     axis image off;

    fm = fftshift(fft2(ifftshift(im)));
end