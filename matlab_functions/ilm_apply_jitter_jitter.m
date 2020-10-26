function[data] = ilm_apply_jitter_jitter(data_i, dxy)
    n_data = ilm_nz_data(data_i);
    data = data_i;
    for idat=1:n_data
        dx = dxy(:, 1, idat);
        dy = dxy(:, 2, idat);
        data(:, :, idat) = ilc_sd_nr_2d(data_i(:, :, idat), 1, 1, dx, dy, 7, 0);
    end
    
%     figure(1); clf;
%     subplot(1, 2, 1);
%     imagesc(ilm_mean_data(data_i));
%     colormap gray;
%     axis image off;
%     subplot(1, 2, 2);
%     imagesc(ilm_mean_data(data));
%     colormap gray;
%     axis image off;
    
%     figure(1); clf;
%     subplot(1, 2, 1);
%     imagesc(im_m-im_r);
%     colormap gray;
%     axis image off;
%     subplot(1, 2, 2);
%     imagesc(im_m_c-im_r);
%     colormap gray;
%     axis image off;
%    
%     figure(2);
%     subplot(2, 1, 1);
%     plot(dxy(:, 1))
%     subplot(2, 1, 2);
%     plot(dxy(:, 2))
    disp('Optical flow equation jitter calculation. Done')
end