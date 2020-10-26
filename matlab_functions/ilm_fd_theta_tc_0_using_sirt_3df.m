function[theta, txy] = ilm_fd_theta_tc_0_using_sirt_3df(system_conf, st_data, theta, txy)
    [ny, nx, n_data] = size(st_data.data);

    for ik=1:n_data
        im = st_data.data(:, :, ik).*st_data.fw_squ_95;
        st_data.data(:, :, ik) = im;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    vol_geom = astra_create_vol_geom(ny, nx, nx);
    proj_geom = astra_create_proj_geom('parallel3d', 1.0, 1.0, ny, nx, st_data.angles);

    proj_id = astra_mex_data3d('create', '-proj3d', proj_geom, permute(st_data.data, [2 3 1]));
    rec_id = astra_mex_data3d('create', '-vol', vol_geom, 0);    
%     mask_id = astra_mex_data3d('create', '-vol', vol_geom, st_data.mask_cyl);
    
    st_sirt = astra_struct('SIRT3D_CUDA');  
    st_sirt.ProjectionDataId = proj_id;
    st_sirt.ReconstructionDataId = rec_id;
%     st_sirt.option.ReconstructionMaskId = mask_id; 
    st_sirt.option.MinConstraint = 0;
    
    alg_id = astra_mex_algorithm('create', st_sirt);
    
    st_sirt.alg_id = alg_id;
    st_sirt.proj_id = proj_id;
    st_sirt.rec_id = rec_id;  
    st_sirt.n_iter = st_data.n_iter_opt;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    ic = 1;
    for dtheta=-10:1:10
        s(ic).x = [theta + dtheta, txy];
        s(ic).ee = fn_get_error_theta(system_conf, st_data, st_sirt, s(ic).x(1), s(ic).x(2:3));
        disp([s(ic).x(1), s(ic).ee])         
        ic = ic + 1;
    end
    s = fn_sort(s);    
    theta = s(1).x(1);
    
    ic = 1;
    for x=-10:1:10
        s(ic).x = [theta, txy + [x, 0]];
        s(ic).ee = fn_get_error_tc(system_conf, st_data, st_sirt, s(ic).x(1), s(ic).x(2:3));
        disp([s(ic).x(2), s(ic).ee])        
        ic = ic + 1;
    end
    s = fn_sort(s);
    txy = s(1).x(2:3);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    astra_mex_algorithm('delete', st_sirt.alg_id);
    astra_mex_data3d('delete', st_sirt.proj_id);    
    astra_mex_data3d('delete', st_sirt.rec_id);
%     astra_mex_data3d('delete', st_sirt.mask_id);

    astra_mex_data3d('clear');
end


function[ee] = fn_get_error_theta(system_conf, st_data, st_sirt, theta, txy)
    txy = txy*ilm_rot_mat_2d(theta);
    data_t = ilm_rot_tr_2d_2_data(system_conf, st_data.data, theta, st_data.p_rc, st_data.tr+txy, st_data.fw_cir_75, st_data.bg_opt, st_data.bg);
    data_t = permute(data_t, [2 3 1]);

    astra_mex_data3d('set', st_sirt.rec_id, 0);
    astra_mex_data3d('set', st_sirt.proj_id, data_t);

    astra_mex_algorithm('iterate', st_sirt.alg_id, st_sirt.n_iter);
    ee = astra_mex_algorithm('get_res_norm', st_sirt.alg_id);
end

function[ee] = fn_get_error_tc(system_conf, st_data, st_sirt, theta, txy)
    fw_squ_75 = ilc_tr_2d(system_conf, st_data.fw_squ_75, 1, 1, txy);

    A = ilm_rot_mat_2d(theta);
    p_rc = st_data.p_rc.';
    txy = A*(st_data.tr.' - p_rc) + p_rc + txy.';
    txy = txy.';
    data_t = ilm_tr_at_2d_2_data(system_conf, st_data.data, A, txy, fw_squ_75, st_data.bg_opt, st_data.bg);

    data_t = permute(data_t, [2 3 1]);
    astra_mex_data3d('set', st_sirt.rec_id, 0);
    astra_mex_data3d('set', st_sirt.proj_id, data_t);

    astra_mex_algorithm('iterate', st_sirt.alg_id, st_sirt.n_iter);
    ee = astra_mex_algorithm('get_res_norm', st_sirt.alg_id);
end

function[s] = fn_sort(s)
    ns = length(s);
    sv = zeros(ns, 1);
    for ik=1:ns
       sv(ik) = s(ik).ee; 
    end
    [~, ii] = sort(sv);
    s = s(ii);
end