% Image normalization based on the mean and std
function [im_o, im_sft, im_sc] = ilm_mean_std_ni(im_i, bd)
    if(nargin<2)
        [im_sft, im_sc] = ilm_mean_std_np(im_i);
    else
        bd = round(bd);
        im_c = ilm_extract_region_using_bd(im_i, bd);
        [im_sft, im_sc] = ilm_mean_std_np(im_c);
    end

    im_o = (im_i-im_sft)/im_sc;
end