function[im]=ilm_bining_image(im_i, nf)
    [ny_i, nx_i] = size(im_i);
    nx = round(nx_i/nf);
    ny = round(ny_i/nf);
    im = im_i;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% bin in x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for ix = 1:nx
        ix_0 = nf*(ix-1)+1;
        ix_e = ix_0 + nf-1;
        im(:, ix) = sum(im(:, ix_0:ix_e), 2);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% bin in y %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for iy = 1:ny
        iy_0 = nf*(iy-1)+1;
        iy_e = iy_0 + nf-1;
        im(iy, :) = sum(im(iy_0:iy_e, :), 1);
    end
    
    im = im(1:ny, 1:nx)/(nf^2);
end