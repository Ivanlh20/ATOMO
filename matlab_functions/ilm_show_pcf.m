function[] = ilm_show_pcf(system_conf, im_r, im_t, at_1, at_2, p, sigma_g, bd)
    dx = 1; 
    dy = 1; 

    [A_1, txy_1] = ilm_cvt_at_v_2_A_txy(at_1);
    [chi2_b, ~] = ilc_chi2_pcf_2d(system_conf, im_r, im_t, dx, dy, A_1, txy_1, p, sigma_g, bd);
    pcf_b = ilc_pcf_2d(system_conf, im_r, im_t, dx, dy, A_1, txy_1, p, sigma_g, bd);

    [A_2, txy_2] = ilm_cvt_at_v_2_A_txy(at_2);
    [chi2, ~] = ilc_chi2_pcf_2d(system_conf, im_r, im_t, dx, dy, A_2, txy_2, p, sigma_g, bd);
    pcf = ilc_pcf_2d(system_conf, im_r, im_t, dx, dy, A_2, txy_2, p, sigma_g, bd);

    figure(2); clf;
    subplot(1, 2, 1);
    imagesc(pcf_b);
    axis image;
    colormap jet;
    title(num2str(chi2_b, '%6.3f'));
    subplot(1, 2, 2);
    imagesc(pcf);
    axis image;
    colormap jet;
    title(num2str(chi2, '%6.3f'));
    
    disp([chi2_b, chi2])
    pause(0.25)
end