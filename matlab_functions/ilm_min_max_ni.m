% Image normalization based on the min and max
function[im_o, im_sft, im_sc] = ilm_min_max_ni(im_i, bd)
    if(nargin<2)
        im_c = im_i;
    else
        bd = round(bd);
        im_c = ilm_extract_region_using_bd(im_i, bd);
    end

    [im_sft, im_sc] = ilm_min_max_np(im_c);
    im_o = (im_i-im_sft)/im_sc;
end