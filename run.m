clear all; clc;

path = 'D:\Eva\tomography_tutorial_Ivan\';
addpath([path, 'mex_bin']);
addpath([path, 'matlab_functions']);
addpath([path, 'astra-1.8/mex']);
addpath([path, 'astra-1.8/tools']);
net = importdata([path, 'stem_net\stem_128_net.mat']);

system_conf = ilm_dflt_system_conf();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path_dir_in = '';
path_dir = 'data\';
% path_dir_in = '\\ematphoto\emattitan\EvaB\2019\190730_bipyramid_Luis\tomo2_2.55Mx\';
% path_dir = 'D:\research\Matlab_code\simulations_Eva\tomo2_2.55Mx\';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% read tomo info %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[fn_list, angles] = ilm_tomo_dir(path_dir_in, '*_1.ser');
bd_p = [64, 64];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% determine g_max and sigma  %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% g_max: It will be used if wiener filter is used
% sigma: It will be used for the time series registration
bb_show_raw = true;      % show raw data
[fim_m, im_1, im_2] = ilm_tomo_mfft_2d_from_files(net, fn_list, bd_p, bb_show_raw);  
g_max = ilm_gui_pcf_sigma(system_conf, fim_m, im_1, im_2);
sigma = ilm_gui_pcf_sigma(system_conf, fim_m, im_1, im_2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% time series registration  %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bb_show_ps = true;      % show projection restoration
bb_show_ts = true;      % show time series restoration
rt_opt = 1;             % 0: raw data, 1: restored data, 2: Wiener filter
bb_first_im = false;    % only process first image
bb_trs = true;          % transpose data
data = ilm_tomo_alignment(system_conf, net, fn_list, sigma, g_max, bd_p, bb_show_ps, bb_show_ts, rt_opt, bb_first_im, bb_trs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save([path_dir, 'data_0.mat'], 'data', 'angles', 'path_dir', '-v7.3', '-nocompression');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% segmentation %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bd_idx = 2;
bd = [1, size(data, 1)];

for ik=1:size(data, 3)
    im_ik = data(:, :, ik);
    [ims_ik, bd_idx, bd] = ilm_gui_2d_segmentation(ilm_dflt_system_conf(), im_ik, bd_idx, bd);
    data(:, :, ik) = max(0, ims_ik);
    
%     figure(1); clf;
%     subplot(1, 2, 1);
%     imagesc(im_ik);
%     colormap gray;
%     axis image off;
%     colorbar;
%     subplot(1, 2, 2);
%     imagesc(ims_ik);
%     colormap jet;
%     axis image off;
%     colorbar;
%     pause(0.10); 
%     
%     disp(ik*100/size(data, 3))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save([path_dir, 'data_1.mat'], 'data', 'angles', 'path_dir', '-v7.3', '-nocompression');

for ik=1:size(data, 3)
    figure(1); clf;
    imagesc(data(:, :, ik));
    colormap gray;
    axis image off;
    colorbar;
    pause(0.10); 
    
    disp(ik*100/size(data, 3))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% tomography aligment %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data = imresize3(data, [1024, 1024, size(data, 3)]);
data = max(0, data);
[data, rec_sel] = ilm_gui_tomo_aligment(ilm_dflt_system_conf(), data, angles);
g_max = ilm_gui_pcf_sigma(ilm_dflt_system_conf(), ilm_mean_abs_fdata(data));

for ik=1:size(data, 3)
    figure(1); clf;
    imagesc(data(:, :, ik));
    colormap gray;
    axis image off;
    colorbar;
    pause(0.10);   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save([path_dir, 'data_2.mat'], 'data', 'angles', 'rec_sel', 'g_max', 'path_dir', '-v7.3', '-nocompression');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cube = ilm_sirt_cstr_3df(data, angles, 20, 25, true, 0.75, rec_sel, g_max);
[ny, nx, nz] = size(cube);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2); clf;
histogram(cube(:))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cube = min(cube, 3e-7);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = [num2str(nx), 'x', num2str(ny), 'x', num2str(nz)];
save(['SIRT_', fn, '.mat'], 'cube', '-v7.3', '-nocompression');
ilm_write_tif(cube, ['SIRT_', fn, '.tif'], 'uint16', true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mfcube = ilm_mfft3d_for_fitting(cube, 0.5, 0.95, g_max);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(['SIRT_mfft_', fn, '.mat'], 'mfcube', '-v7.3','-nocompression');
ilm_write_tif(mfcube, ['SIRT_mfft_', fn, '.tif'], 'uint16', true);