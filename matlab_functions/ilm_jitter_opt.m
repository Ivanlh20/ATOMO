function[dx, dy] = ilm_jitter_opt(im_r, im_n, dx_i, dy_i, dy_r)
%    im_s = ilc_sd_nr_2d(im_n, 1, 1, dx_i, dy_i);
    [ny, nx] = size(im_r);
    dy_a = -4:0.1:4;
    n_dy_a = length(dy_a);
    n_dy_h = round(n_dy_a/2);
    n_dy_a = 2*n_dy_h;
    for ir = 62:ny
        iy_0 = ir-n_dy_h;
        iy_e = ir+n_dy_h-1;
        dy_ir = dy_i(ir) + (-n_dy_h:1:(n_dy_h-1))*0.1;

        im_nc = im_n(iy_0:iy_e, :);
%         im_rc = im_r(iy_0:iy_e, :);    
         
        im_p = ilc_sft_2d_br(repmat(im_r(ir, :), n_dy_a, 1), 1, 1, dx_i(iy_0:iy_e));
        
%         im_p = ilc_sd_nr_2d(im_rc, 1, 1, dx_i, dy_ir);
        
        figure(1); clf;
        subplot(4, 1, 1);
        imagesc(im_nc);
        colormap jet;
        axis image off; 

        subplot(4, 1, 2);
        imagesc(im_p);
        colormap jet;
        axis image off;

        subplot(4, 1, 3);
        imagesc(im_nc-im_p);
        colormap jet;
        axis image off; 
        
        subplot(4, 1, 4);
        plot(dy_ir, mean(abs(im_nc-im_p), 2), '-+r')
        disp(dy_r(ir))
    end  
end