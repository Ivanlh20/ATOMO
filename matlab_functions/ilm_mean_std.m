% get mean and std
function[im_mean, im_std] = ilm_mean_std(im_i)
    im_mean = mean(im_i(:));
    im_std = std(im_i(:));
end