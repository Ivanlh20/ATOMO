% get brightness-contrast ratio
function[bc_r] = ilm_bcr(im_i)
    [im_mean, im_std] = ilm_mean_std(im_i);
    bc_r = im_mean/im_std;
end