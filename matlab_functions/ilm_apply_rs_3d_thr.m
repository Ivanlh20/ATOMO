function[cube]=ilm_apply_rs_3d_thr(cube, f_th, bb_show, bb_sqrt)
    if(nargin<4)
       bb_sqrt = true;
    end
    
    if(nargin<3)
       bb_show = false;
    end
    
    if(nargin<2)
        f_th = 0.5;
    end
    
    mask = ilm_get_mask_3d_thr(cube, f_th, bb_sqrt);
    cube = cube.*mask;

    if(bb_show)
        figure(2); clf;
        subplot(1, 2, 1);
        imagesc(squeeze(mean(cube, 2)));
        colormap hot
        axis image;
    end
    
    cube = cube.*mask;
    
    if(bb_show)
        figure(2);
        subplot(1, 2, 2);
        imagesc(squeeze(mean(cube, 2)));
        colormap hot
        axis image;
    end
end