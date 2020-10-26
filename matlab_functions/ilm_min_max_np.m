% get normalization parameters based on the min and max
function[im_sft, im_sc] = ilm_min_max_np(im_i)
    [im_min, im_max] = ilm_min_max(im_i);    
    im_sft = im_min;
    im_sc = im_max-im_min;    
end