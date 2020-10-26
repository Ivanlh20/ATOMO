function [mfim, im_1, im_2] = ilm_tomo_mfft_2d_from_files(net, fn_list, bd_p, bb_show_raw)   
    if(nargin<4)
        bb_show_raw = false;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    info = ilm_read_info_ser(fn_list{1});
    nx = info.nx;
    ny = info.ny;
    n_data = numel(fn_list);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    std_max = 0;
    ik_f_max = 1;
    for ik_f=1:n_data
        im_std_max = double(ilm_read_ser(fn_list{ik_f}, 1, 1));
        
        std_ik = std(im_std_max(:));
        if(std_ik>std_max)
            std_max = std_ik;
            ik_f_max= ik_f;
        end
        
        if(bb_show_raw)
            figure(1); clf;
            imagesc(im_std_max);
            colormap gray;
            axis image off;
        end

        disp(['percentate = ', num2str(100*ik_f/n_data, '%3.1f'), ' %']);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    im_std_max = double(ilm_read_ser(fn_list{ik_f_max}));
    im_1 = ilm_nn_stem_data_rt(net, im_std_max(:, :, 1), 0);
    im_2 = ilm_nn_stem_data_rt(net, im_std_max(:, :, end), 0);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bd_p = [ilm_pn_border(nx, bd_p(1)), ilm_pn_border(ny, bd_p(2))];
    nx = nx + 2*bd_p(1);
    ny = ny + 2*bd_p(2);

    bg_opt = 3;
    fr = 0.95;
    radius_p = round(fr.*[nx, ny]/2);
    f_x = ilc_func_butterworth(nx, 1, 1, 1, radius_p(1), 16, 0);
    f_y = ilc_func_butterworth(1, ny, 1, 1, radius_p(2), 16, 0);
    f_w = f_x.*f_y;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bg = ilm_get_bg(im_1, bg_opt, 0);
    im_1b = ilc_add_bd_pbc(im_1, bd_p);
    im_1b = (im_1b-bg).*f_w;
    
    bg = ilm_get_bg(im_2, bg_opt, 0);
    im_2b = ilc_add_bd_pbc(im_2, bd_p);
    im_2b = (im_2b-bg).*f_w;
    
    mfim = 0.5*(abs(fft2(im_1b)) + abs(fft2(im_2b)));
    mfim = ifftshift(mfim);
end