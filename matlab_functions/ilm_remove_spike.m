function[data]=ilm_remove_spike(data)
[ny, nx, n_data] = size(data);
[rx, ry] = meshgrid(1:nx, 1:ny);
f = 0.9975;
for ik=1:n_data
    im_ik = double(data(:, :, ik));
    [i_min, i_max] = ilm_min_max(im_ik);
    thr_0 = i_min + (1-f)*(i_max-i_min);
    thr_e = i_min + f*(i_max-i_min);
    idx = find((im_ik>thr_e)|(im_ik<thr_0));
    xy = [rx(idx), ry(idx)]-1;
    im_ik_rm = ilc_rm_dead_pixels(im_ik, 1, xy);
    im_ik(idx) = im_ik_rm(idx);
    data(:, :, ik) = im_ik;
    
%     figure(1); clf;
%     subplot(1, 2, 1);
%     imagesc(data(:, :, ik));
%     colormap gray;
%     axis image off;
%     colorbar;
%     subplot(1, 2, 2);
%     mesh(im_ik);
%     colormap jet;
%     axis image off;
%     colorbar;
%     pause(0.25); 
end