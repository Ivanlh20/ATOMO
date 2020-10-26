function[at_p_b, at_p_u]=ilm_hysitron_video_proc(file_name, system_conf, rect_b, rect_u, sigma_g, n_iter)
    if(nargin<6)
        n_iter = 2;
    end
    
    if(nargin<5)
        sigma_g = 30;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    info = ilm_read_info_video(file_name, sym_crop);
    ax = info.ix_0:info.ix_e;
    ay = info.iy_0:info.iy_e;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    radius = ilm_sigma_g_2_sigma_r(info.nx, info.ny, sigma_g);
    
    bd = [0, 0, 0, 0];
    at_p_b = ilm_dflt_at_p(info.n_data);
    at_p_u = ilm_dflt_at_p(info.n_data);  
    fw_b = ilm_func_butterworth_rect(info.nx, info.ny, rect_b, 16);   % lower part
    fw_u = ilm_func_butterworth_rect(info.nx, info.ny, rect_u, 16);   % upper part
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    d_ik = round(0.02*info.n_data);
    for it = 1:n_iter
        videoFReader = vision.VideoFileReader(file_name, 'VideoOutputDataType', 'uint8', 'ImageColorSpace', 'Intensity');
        
        im_r = videoFReader();
        im_r = double(im_r(ay, ax));
        im_r_b_m = ilm_apply_mask(im_r, fw_b);
        im_r_u_m = ilm_apply_mask(im_r, fw_u);
    
        ik_0 = 1;
        for ik = 2:info.n_data
            im_s = videoFReader();
            im_s = double(im_s(ay, ax));

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            im_s_b_m = ilm_apply_mask(im_s, fw_b);
            [A, txy] = ilm_cvt_at_v_2_A_txy(at_p_b(ik, :));
            at_p_b(ik, 5:6) = ilc_fd_tr_2d(system_conf, im_r_b_m, im_s_b_m, 1, 1, A, txy, 0.05, sigma_g, bd, 1, 0, 1, radius);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            im_s_u_m = ilm_apply_mask(im_s, fw_u);
            [A, txy] = ilm_cvt_at_v_2_A_txy(at_p_u(ik, :));
            at_p_u(ik, 5:6) = ilc_fd_tr_2d(system_conf, im_r_u_m, im_s_u_m, 1, 1, A, txy, 0.05, sigma_g, bd, 1, 0, 1, radius);
            
%             figure(1); clf;
%             subplot(1, 2, 1);
%             imagesc(im_s_b_m);
%             axis image;
%             colormap gray;
%             subplot(1, 2, 2);
%             imagesc(im_s_u_m);
%             axis image;
%             colormap hot;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if(ik>ik_0)
                ik_0 = ik_0 + d_ik;
                disp(['iter = ', num2str(it), '/', num2str(n_iter), ' - percentage = ', num2str(100*ik/n_data)]);
            end
        end 
    end
end
