function[cube]=ilm_apply_fs_3d_thr(cube, n, mask_ept, bb_show)
    if(nargin<3)
       bb_show = false;
    end
    
    if(nargin<2)
        n = 0.5;
    end
    
    fcube = fftn(cube).*mask_ept;
%     mfcube = abs(fcube).^n;
%     mfcube(1) = mfcube(2);
%     level = mean(mfcube(:));
%     fcube(mfcube < level) = 0;
    
    if(bb_show)
        figure(1); clf;
%         subplot(1, 2, 1);
%         imagesc(squeeze(mean(ifftshift(mfcube).^n, 3)));
%         colormap hot
%         axis image;
%         subplot(1, 2, 2);
        imagesc(squeeze(mean(ifftshift(abs(fcube)).^n, 3)));
        colormap hot
        axis image;
    end
    
    cube = max(0, real(ifftn(fcube)));
end