function[im_ch] = ilm_add_alpha_channel(im, im_bin, thr)
    if(nargin<3)
        thr = 0.825;
    end
    im_ch = im;
    fg = im_ch(im_bin);
    sft = (1-thr)*(max(fg)- min(fg));
    
    im_bin_c = ~im_bin;
    im_ch(im_bin_c) = sft + im_ch(im_bin_c);
end
