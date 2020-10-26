function[im_ext] = ilm_extract_region(im_i, ix_0, ix_e, iy_0, iy_e)
    if(nargin<3)
        p = ix_0;
        im_ext = im_i(p(1, 2):p(2, 2), p(1, 1):p(2, 1));
        return;
    end
    
    [ny_i, nx_i, ~] = size(im_i);
    
    ix_s0 = max(1, ix_0);
    ix_se = min(nx_i, ix_e);
    iy_s0 = max(1, iy_0);
    iy_se = min(ny_i, iy_e);

    im_ext = im_i(iy_s0:iy_se, ix_s0:ix_se, :);
    [ny_p, nx_p, ~] = size(im_ext);

    if(ix_0<1)
        bx_0 = 1-ix_0;
        ax_0 = (bx_0:-1:1)+1;
        im_ext = [im_ext(:, ax_0, :), im_ext]; 
    elseif(ix_e>nx_i)
        bx_e = ix_e-nx_i;
        ax_e = (nx_p-1)-(1:1:bx_e);
        im_ext = [im_ext, im_ext(:, ax_e, :)];           
    end

    if(iy_0<1)
        by_0 = 1-iy_0;
        ay_0 = (by_0:-1:1)+1;
        im_ext = [im_ext(ay_0, :, :); im_ext]; 
    elseif(iy_e>ny_i)
        by_e = iy_e-ny_i;
        ay_e = (ny_p-1)-(1:1:by_e);
        im_ext = [im_ext; im_ext(ay_e, :, :)];           
    end
end