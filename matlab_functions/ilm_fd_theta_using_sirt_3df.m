function[theta] = ilm_fd_theta_using_sirt_3df(system_conf, st_data, theta, txy, dtheta)
    [ny, nx, n_data] = size(st_data.data);

    if(nargin<5)
        dtheta = 1;
    end

    if(nargin<4)
        txy = [0, 0];
    end

    if(nargin<3)
       theta = 0;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    vol_geom = astra_create_vol_geom(ny, nx, nx);
    proj_geom = astra_create_proj_geom('parallel3d', 1.0, 1.0, ny, nx, st_data.angles);

    proj_id = astra_mex_data3d('create', '-proj3d', proj_geom, permute(st_data.data, [2 3 1]));
    rec_id = astra_mex_data3d('create', '-vol', vol_geom, 0);    
%     mask_id = astra_mex_data3d('create', '-vol', vol_geom, st_data.mask_cyl);
    proj_fp_id = astra_mex_data3d('create', '-sino', proj_geom, 0);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    st_fp3d = astra_struct('FP3D_CUDA');
    st_fp3d.ProjectionDataId = proj_fp_id;
    st_fp3d.VolumeDataId = rec_id;
    
    alg_fp_id = astra_mex_algorithm('create', st_fp3d);   
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    st_sirt = astra_struct('SIRT3D_CUDA');  
    st_sirt.ProjectionDataId = proj_id;
    st_sirt.ReconstructionDataId = rec_id;
%     st_sirt.option.ReconstructionMaskId = mask_id; 
    st_sirt.option.MinConstraint = 0;
    
    alg_id = astra_mex_algorithm('create', st_sirt);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    st_rec.alg_fp_id = alg_fp_id;    
    st_rec.proj_fp_id = proj_fp_id;
    
    st_rec.alg_id = alg_id;
    st_rec.proj_id = proj_id;
    st_rec.rec_id = rec_id;
%     st_rec.mask_id = mask_id;    
    st_rec.n_iter = st_data.n_iter_opt;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    alpha = 1;
    gamma = 2.0;
    rho = 0.5;
    sigma = 0.5;
    
    s(1).x = [theta, txy];
    s(1).ee = fn_get_error(system_conf, st_data, st_rec, s(1).x(1), s(1).x(2:3));

    s(2).x = [theta + dtheta, txy];
    s(2).ee = fn_get_error(system_conf, st_data, st_rec, s(2).x(1), s(2).x(2:3));

    s = fn_sort(s); 
    
    ni_t = st_data.n_iter_nm_theta;
    for it=1:ni_t
        x_0 = fn_xc(s);

        x_r = x_0 + alpha*(x_0-s(end).x);
        ee_r = fn_get_error(system_conf, st_data, st_rec, x_r(1), x_r(2:3));
        if(ee_r<s(1).ee)
            x_e = x_0 + gamma*(x_r-x_0);
            ee_e = fn_get_error(system_conf, st_data, st_rec, x_e(1), x_e(2:3));   
            if(ee_e<ee_r)
                s(end).x = x_e;
                s(end).ee = ee_e;   
            else
                s(end).x = x_r;
                s(end).ee = ee_r;                
            end
        elseif(ee_r<s(end-1).ee)
            s(end).x = x_r;
            s(end).ee = ee_r;
        else
            if(ee_r<s(end).ee)            
                x_c = x_0 + rho*(x_r-x_0);
                ee_c = fn_get_error(system_conf, st_data, st_rec, x_c(1), x_c(2:3));
            else
                x_c = x_0 + rho*(s(end).x-x_0);
                ee_c = fn_get_error(system_conf, st_data, st_rec, x_c(1), x_c(2:3));                
            end
            
            if(ee_r<ee_c)
                x_c = x_r;
                ee_c = ee_r;
            end
            
            s(end).x = x_c;
            s(end).ee = ee_c;
        end
        
        s = fn_sort(s); 
        
        disp(['p = ', num2str(100*it/ni_t), ', theta = ', num2str(s(1).x(1), '%5.3f'), ', x = ', num2str(s(1).x(2), '%5.3f'), ', y = ', num2str(s(1).x(3), '%5.3f'), ', error = ', num2str(s(1).ee, '%8.6f')])
        if(norm(s(2).x-s(1).x)<0.1)
            break;
        end        
    end

    theta = s(1).x(1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    astra_mex_algorithm('delete', st_rec.alg_fp_id);
    astra_mex_algorithm('delete', st_rec.proj_fp_id);
    
    astra_mex_algorithm('delete', st_rec.alg_id);
    astra_mex_data3d('delete', st_rec.proj_id);    
    astra_mex_data3d('delete', st_rec.rec_id);
%     astra_mex_data3d('delete', st_rec.mask_id);

    astra_mex_data3d('clear');
end

function[ee] = fn_get_error(system_conf, st_data, st_rec, theta, txy)
    tr = st_data.tr+txy*ilm_rot_mat_2d(theta);
    data_t = ilm_rot_tr_2d_2_data(system_conf, st_data.data, theta, st_data.p_rc, tr, st_data.fw_cir_95, 6, 0);
    mask_proj = ilm_rot_tr_2d_2_data(system_conf, st_data.mask_proj, theta, st_data.p_rc, tr, st_data.fw_cir_50, 6, 0);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    astra_mex_data3d('set', st_rec.rec_id, 0);
    astra_mex_data3d('set', st_rec.proj_id, permute(data_t, [2 3 1]));

    astra_mex_algorithm('iterate', st_rec.alg_id, st_rec.n_iter);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     cube = astra_mex_data3d('get', st_rec.rec_id);
%     cube = cube.*st_data.fw_cir_mask;
%     astra_mex_data3d('set', st_rec.rec_id, cube);

    astra_mex_algorithm('iterate', st_rec.alg_fp_id);
    data_p = astra_mex_data3d('get', st_rec.proj_fp_id);
    data_p = permute(data_p, [3 1 2]);
    
    mask_proj = double(mask_proj>0.95);
%     mask_proj = double(mask_proj>0.5).*st_data.fw_sel_theta;
    data_p = abs(data_p - data_t).*mask_proj;
    ee = sum(data_p(:));
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

function[xc] = fn_xc(s)
    ns = length(s)-1;
    xc = zeros(size(s(1).x));
    for ik=1:ns
       xc = xc + s(ik).x; 
    end
    xc = xc/ns;
end