function[thr]=ilm_retrieve_threshold(im_i, p_r)
    im_i  = im_i(:);
    nn = numel(im_i);
    thr_0 = min(im_i);
    thr_e = mean(im_i);

    thr = 0.5*(thr_0+thr_e);
    p_c = sum(im_i>thr)/nn;
    ic = 1;
    while abs(p_c-p_r)>1e-3
        if(p_c>p_r)
            thr_0 = thr;
        else
            thr_e = thr;
        end
        
        thr = 0.5*(thr_0+thr_e);
        p_c = sum(im_i>thr)/nn;
        
        ic = ic + 1;
        if(ic>20)
            break;
        end
    end
end