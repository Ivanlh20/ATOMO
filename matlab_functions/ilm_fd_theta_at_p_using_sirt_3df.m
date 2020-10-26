function[theta, at_p] = ilm_fd_theta_at_p_using_sirt_3df(data, angles, theta, at_p, f_r, n_iter, bb_fi, bg_theta, bb_n_theta, bg_tc, bb_n_tc, n_opt)
    system_conf.precision = 2; % eP_Float = 1, eP_double = 2
    system_conf.device = 2; % eD_CPU = 1, eD_GPU = 2
    system_conf.cpu_nthread = 1;
    system_conf.gpu_device  = 0;

    if(nargin<11)
        n_opt = 25;
    end
    
    if(nargin<10)
        bb_n_tc = true;
    end

    if(nargin<9)
        bg_tc = 0.75;
    end
    
    if(nargin<8)
        bb_n_theta = true;
    end

    if(nargin<7)
        bg_theta = 0.5;
    end
    
    if(nargin<6)
        bb_fi = true;
    end
    
    if(nargin<5)
        n_iter = 5;
    end
    
    at_p(:, 5:6) = at_p(:, 5:6)*f_r;
    data_t = ilm_resize_2_data(data, f_r);
    data_t = fn_data_norm(data_t, bg_theta, bb_n_theta);
    [ny_i, nx_i, n_data] = ilm_size_data(data_t);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    radius = 0.95*nx_i/2;
    fw_squ_95 = ilc_func_butterworth(nx_i, 1, 1, 1, radius, 32, 0, [0, 0, 0, 0], [nx_i, ny_i]/2-0.5);
    fw_squ_95 = fw_squ_95.*(fw_squ_95.');
    
    nx = ilc_pn_fact(round(1.4142*nx_i));
    ny = nx;
    ix_0 = (nx-nx_i)/2+1;
    ix_e = ix_0 + nx_i - 1;
    ax = ix_0:ix_e;
    
    iy_0 = (ny-ny_i)/2+1;
    iy_e = iy_0 + ny_i - 1;    
    ay = iy_0:iy_e;
    
    data = zeros(ny, nx, n_data);
    mask_proj = zeros(ny, nx, n_data);
    for ik=1:n_data
        im = data_t(:, :, ik).*fw_squ_95;
        data(ay, ax, ik) = im;
        mask_proj(ay, ax, ik) = fw_squ_95;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%% find shift and tilt %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    shift = 0;
    bd = zeros(1, 4);
    p_c = [nx, ny]/2-0.5;
    
    radius = 0.95*nx/2;
    fw_sel_theta = ilc_func_butterworth(nx, ny, 1, 1, radius, 12, shift, bd, p_c);
    fw_sel_theta = double(fw_sel_theta>0.95);
    
    radius = 0.95*nx/2;
    fw_sel_tr = repmat(ilc_func_butterworth(nx, 1, 1, 1, radius, 12, shift, bd, p_c), ny, 1);
    fw_sel_tr = double(fw_sel_tr>0.95);
    
    radius = 0.975*nx/2;
    fw_cir_mask = ilc_func_butterworth(nx, ny, 1, 1, radius, 12, shift, bd, p_c);
    fw_cir_mask = double(fw_cir_mask>0.5);
    
    radius = 0.75*nx/2;
    fw_cir_50 = ilc_func_butterworth(nx, ny, 1, 1, radius, 12, shift, bd, p_c);
    
    radius = 0.75*nx/2;
    fw_cyl_50 = repmat(ilc_func_butterworth(nx, 1, 1, 1, radius, 12, shift, bd, p_c), ny, 1);
    
    radius = 0.95*nx/2;
    fw_cir_95 = ilc_func_butterworth(nx, ny, 1, 1, radius, 12, shift, bd, p_c);
    
    radius = 0.95*nx/2;
    fw_cyl_95 = repmat(ilc_func_butterworth(nx, 1, 1, 1, radius, 12, shift, bd, p_c), ny, 1);
    
    radius = 0.95*nx/2;
    fw_squ_95 = ilc_func_butterworth(nx, 1, 1, 1, radius, 12, shift, bd, p_c);
    fw_squ_95 = fw_squ_95.*(fw_squ_95.');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    st_data.n_iter_f = 250;
    st_data.n_iter_opt = n_opt;
    
    st_data.n_iter_nm_tc = 12;
    st_data.n_iter_nm_theta = 12;
    st_data.n_iter_nm_tr = 10;

    st_data.angles = angles;
    
    st_data.fw_sel_theta = fw_sel_theta;
    st_data.fw_sel_tr = fw_sel_tr;
    
    st_data.fw_cir_mask = fw_cir_mask;
    
    st_data.fw_cir_50 = fw_cir_50;    
    st_data.fw_cyl_50 = fw_cyl_50;
    
    st_data.fw_cir_95 = fw_cir_95;    
    st_data.fw_cyl_95 = fw_cyl_95;
    st_data.fw_squ_95 = fw_squ_95;
    
%     st_data.mask_cyl = mask_cyl;
    st_data.mask_proj = mask_proj;

    st_data.p_rc = [nx, ny]/2 - 0.5;
    st_data.tr = at_p(:, 5:6);
    st_data.pp = 0;
    st_data.data = data;
    
    dtheta = 1.0;
    dtxy = [1.0, 0.0];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    tt = 0;
    if(bb_fi)
%         st_data.data = fn_data_norm(data, bg_theta, bb_n_theta);
        theta = ilm_fd_theta_using_sirt_3df(system_conf, st_data, theta, [0, 0], dtheta);
%         st_data.data = fn_data_norm(data, bg_tc, bb_n_tc);
        for it=1:n_iter
            txy = ilm_fd_tc_using_sirt_3df(system_conf, st_data, theta, [0, 0], dtxy);
            st_data.tr = st_data.tr + txy*ilm_rot_mat_2d(theta);
            tt = tt + txy(1);
            if(abs(txy(1))<0.1)
                break
            end
            disp(tt)        
        end 
    else
        for ik=1:n_iter
            st_data.data = fn_data_norm(data, bg_theta, bb_n_theta);
            theta = ilm_fd_theta_using_sirt_3df(system_conf, st_data, theta, [0, 0], dtheta);

            st_data.data = fn_data_norm(data, bg_tc, bb_n_tc);
            txy = ilm_fd_tc_using_sirt_3df(system_conf, st_data, theta, [0, 0], dtxy);
            st_data.tr = st_data.tr + txy*ilm_rot_mat_2d(theta);
            tt = tt + txy(1);
            disp(tt) 
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     d_pp = 1.0/n_iter;
%     for it=1:n_iter
%         st_data.pp = d_pp*it;
%         txy = ilm_fd_tr_using_sirt_3df(system_conf, st_data, theta, [0, 0], dtxy, st_data.pp);
%         st_data.tr = st_data.tr+txy; 
%         
%         disp(['Iter = ', num2str(it), '/', num2str(n_iter)])
%     end
%     
%     for it=1:4
%         theta = ilm_fd_theta_using_sirt_3df(system_conf, st_data, theta, [0, 0], dtheta);
%         txy = ilm_fd_tc_using_sirt_3df(system_conf, st_data, theta, [0, 0], dtxy);
%         st_data.tr = st_data.tr+txy*ilm_rot_mat_2d(theta);
%         
%         tt = tt + txy(1);
%         disp(tt)            
%     end 
    
%     st_data.data = ilm_rot_tr_2d_2_data(system_conf, data, theta, st_data.p_rc, st_data.tr+txy, st_data.fw_cir_85);
%     [theta, txy] = ilm_fd_tc_theta_using_sirt_3df(system_conf, st_data, st_data.n_iter_nm_st, theta_0, txy_0, dtheta_0, dtxy_0);
%     
%     st_data.tr = st_data.tr+txy;    
    at_p(:, 5:6) = st_data.tr/f_r;
end