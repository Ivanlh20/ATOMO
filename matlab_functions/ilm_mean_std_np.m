% get normalization parameters based on the mean and std
function[im_sft, im_sc] = ilm_mean_std_np(im_i)
    [im_mean, im_std] = ilm_mean_std(im_i);   
    im_sft = im_mean;
    im_sc = im_std;    
end