function[im_o] = ilm_tri_2d(im_i, txy, bg_opt, bg)
    if(nargin<4)
        bg = 0;
    end
        
    if(nargin<3)
        bg_opt = 1;
    end
    
    im = squeeze(im_i);
    bg = ilm_get_bg(im, bg_opt, bg);
    [ny, nx] = size(im);

    if(txy(1)>0)
        ix_0 = txy(1)+1;
        ix_e = nx;
    else
        ix_0 = 1;
        ix_e = nx+txy(1);
    end
    
    if(txy(2)>0)
        iy_0 = txy(2)+1;
        iy_e = ny;
    else
        iy_0 = 1;
        iy_e = nx+txy(2);
    end
    
    im = circshift(circshift(im, txy(1), 2), txy(2), 1);
    
    im_o = im_i;
    im_o(:) = bg;
    im_o(iy_0:iy_e, ix_0:ix_e) = im(iy_0:iy_e, ix_0:ix_e);
    im_o = reshape(im_o, size(im_i));
end