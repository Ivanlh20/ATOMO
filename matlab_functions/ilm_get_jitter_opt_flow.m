function[dxy] = ilm_get_jitter_opt_flow(im_r, data_i, n_iter)
    [ny, nz, n_data] = ilm_size_data(data_i);

    %%%%%%%%%%%%%%%% optimization %%%%%%%%%%%%%%%%%
    data = data_i;
    dxy = zeros(ny, 2, n_data);
    for it=1:n_iter
        [Gy, Gx] = gradient(im_r.'); 
        ee = 0;
        for idat=1:n_data
            im_m = data_i(:, :, idat);
            im_ms = (im_m-im_r).';
            for ir = 1:ny
                dxy(ir, :, idat) = [Gx(:, ir), Gy(:, ir)]\im_ms(:, ir);
            end 
            dx = dxy(:, 1, idat);
            dy = dxy(:, 2, idat);
            im_c = ilc_sd_nr_2d(im_m, 1, 1, dx, dy, 7, 0);
            data(:, :, idat) = im_c;
            ee = ee + mean(abs(im_m(:)-im_r(:)))/n_data;
            
%             figure(1); clf;
%             subplot(2, 2, 1);
%             imagesc(im_m);
%             colormap gray;
%             axis image off;
%             subplot(2, 2, 2);
%             imagesc(im_r);
%             colormap gray;
%             axis image off;
%             
%             subplot(2, 2, 3);
%             imagesc(im_m-im_r);
%             colormap gray;
%             axis image off;
%             subplot(2, 2, 4);
%             imagesc(im_c-im_r);
%             colormap hot;
%             axis image off;
%             [it, mean(abs(im_m(:)-im_r(:))), mean(abs(im_c(:)-im_r(:)))]
        end
        disp(['Iter = ', num2str(it) , ' - Error = ', num2str(ee, '%7.3f')])
        im_r = ilm_mean_data(data);
    end
    disp('Optical flow equation jitter calculation. Done')
    
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

end