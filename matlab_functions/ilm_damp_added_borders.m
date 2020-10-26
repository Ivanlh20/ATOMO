function[im]=ilm_damp_added_borders(im_i, bd_p, bg_opt, bg)
    if(nargin<4)
        bg = 0;
    end
        
    if(nargin<3)
        bg_opt = 1;
    end
    
    [ny_i, nx_i] = size(im_i);
    
%     im_i(1, 50:end) = 1.0;
%     im_i(end, 50:end) = 1.0;
%     im_i(50:end, 1) = 1.0;
%     im_i(50:end, end) = 1.0;
    

    bg = ilm_get_bg(im_i, bg_opt, bg);
    im = ilc_add_bd_pbc(im_i, bd_p);
    
%     figure(1); clf;
%     subplot(1, 2, 1);
%     imagesc(im);
%     axis image off;
%     colormap jet;
    
    [ny, nx] = size(im);
    bd = [2, 2, 2, 2];
    n = 32;
    fw_x = ilc_func_butterworth(nx, 1, 1, 1, nx_i/2, n, 0, bd, [nx/2-0.5, 0]);
    fw_x = ilm_min_max_ni(fw_x);
    fw_y = ilc_func_butterworth(1, ny, 1, 1, ny_i/2, n, 0, bd, [ny/2-0.5, 0]);
    fw_y = ilm_min_max_ni(fw_y);
    fw_squ = fw_x.*fw_y;

    im = (im-bg).*fw_squ + bg;
    
%     figure(1);   
%     subplot(1, 2, 2);
%     imagesc(im);
%     axis image off;
%     colormap gray;
end