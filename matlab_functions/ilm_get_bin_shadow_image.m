function[im_sb]=ilm_get_bin_shadow_image(im_e, ups_factor, bd_p)
    im_si = ilm_sinc_2d_interpolation(im_e, ups_factor, bd_p);
    im_si = max(0, min(1, im_si));
    thr = ilc_otsu_thr(im_si, 512);
    
    
    %%%%%%% set threshdold in order to obtained the same mean value %%%%%%%
    im_sb = ilm_bining_image(double(im_si>thr), ups_factor);
    
    v_r = mean(im_e(:));
    v = mean(im_sb(:));
    
    if(v_r<v)
        f_0 = (1+thr)/2; 
        f_e = thr;
    else
        f_0 = thr;
        f_e = (0+thr)/2;
    end
    
    for ik=1:8
        f = (f_0+f_e)/2;
        im_sb = ilm_bining_image(double(im_si>f), ups_factor);
        v = mean(im_sb(:));
        if(v_r<v)
            f_e = f;
        else
            f_0 =f;
        end 
%         num2str([v_r, v], 8)
    end
end