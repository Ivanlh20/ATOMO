function[dx, dy] = ilm_jitter_opt_btw_2(im_r, im_n, dxy_1, dxy_2)

    im_r11 = ilc_sd_r_2d(im_r, 1, 1, dxy_1(:, 1), dxy_1(:, 2));
    im_r12 = ilc_sd_r_2d(im_r, 1, 1, dxy_1(:, 1), dxy_2(:, 2));
    im_r21 = ilc_sd_r_2d(im_r, 1, 1, dxy_2(:, 1), dxy_1(:, 2));    
    im_r22 = ilc_sd_r_2d(im_r, 1, 1, dxy_2(:, 1), dxy_2(:, 2));
    
    dxy_j = [dxy_1(:, 1) + [0:1:];
    dxy_j = [dxy_1; dxy_2];
    
    bd = zeros(1, 4);
    bd(1) = abs(max(dxy_j(dxy_j(:, 1)>=0, 1)));     
    bd(2) = abs(min(dxy_j(dxy_j(:, 1)<=0, 1)));
    bd(3) = abs(max(dxy_j(dxy_j(:, 2)>=0, 2)));     
    bd(4) = abs(min(dxy_j(dxy_j(:, 2)<=0, 2)));

    im_r1 = ilc_set_bd(im_r1, 1, 1, bd, 6, 0);
    im_r2 = ilc_set_bd(im_r2, 1, 1, bd, 6, 0);
    im_n = ilc_set_bd(im_n, 1, 1, bd, 6, 0);
    
    
    figure(1); clf;
    subplot(2, 3, 1);
    imagesc(im_n-im_r1);
    colormap jet;
    axis image off; 

    subplot(2, 3, 2);
    imagesc(im_n-im_r2);
    colormap jet;
    axis image off;

    subplot(2, 3, 3);
    imagesc(im_n);
    colormap jet;
    axis image off;
    
    subplot(2, 3, 4:6);
    t = mean(abs(im_n-im_r1), 2);
    plot(t, '-r') 
    hold on;
    t = mean(abs(im_n-im_r2), 2);
    plot(t, '-b')     
    
%     dx = dxy(:, 1);
%     dy = dxy(:, 2);    
end