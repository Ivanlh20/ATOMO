function[txy] = ilm_fd_tr_using_sirt_3df(system_conf, st_data, theta, txy, dtxy, pp)
    [ny, nx, n_data] = size(st_data.data);

    if(nargin<6)
        pp = 1;
    end
    
    if(nargin<5)
        dtxy = [1, 0];
    end
    
    if(nargin<4)
        txy = repmat([0, 0], n_data, 1);
    end

    if(nargin<3)
       theta = 0;
    end
    
    if(size(txy, 1)==1)
        txy = repmat(txy, n_data, 1);
    end
    
    for ik=1:n_data
        im = st_data.data(:, :, ik);
%         st_data.bg(ik) = 0;
        
        im = (im-st_data.bg(ik)).*st_data.fw_squ_95 + st_data.bg(ik);
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
%     st_sirt.mask_id = mask_id;    
    st_sirt.n_iter = st_data.n_iter_opt;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    n_data_sel = min(n_data, round(pp*n_data));
    n_data_opt_h = ceil(n_data_sel/2);
    a_idx = cumsum(ones(n_data_sel, 1));
    ic = 1;
    for ik=1:n_data_opt_h
        if(ic<=n_data_sel)
            a_idx(ic) = ik;
        end
        if(ic+1<=n_data_sel)
            a_idx(ic+1) = n_data-(ik-1);
        end
        ic = ic + 2;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    alpha = 1;
    gamma = 2;
    rho = 0.75;
    sigma = 0.75;

    ni_t = st_data.n_iter_nm_tr;

    for ik_s=1:n_data_sel
        ik = a_idx(ik_s);
        
        s(1).x = [theta, txy(ik, :)];
        s(1).ee = fn_get_error(system_conf, st_data, st_sirt, s(1).x(1), s(1).x(2:3), ik);

        s(2).x = [theta, txy(ik, :) + dtxy];
        s(2).ee = fn_get_error(system_conf, st_data, st_sirt, s(2).x(1), s(2).x(2:3), ik);
        
        s = fn_sort(s); 
        
        for it=1:ni_t
            x_0 = fn_xc(s);

            x_r = x_0 + alpha*(x_0-s(end).x);
            ee_r = fn_get_error(system_conf, st_data, st_sirt, x_r(1), x_r(2:3), ik);
            if(ee_r<s(1).ee)
                x_e = x_0 + gamma*(x_r-x_0);
                ee_e = fn_get_error(system_conf, st_data, st_sirt, x_e(1), x_e(2:3), ik); 
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
                x_c = x_0 + rho*(s(end).x-x_0);
                ee_c = fn_get_error(system_conf, st_data, st_sirt, x_c(1), x_c(2:3), ik);
                if((ee_c<s(end).ee)||(length(s)==2))
                    s(end).x = x_c;
                    s(end).ee = ee_c;
                else
                   s = fn_shrink(system_conf, s, sigma, st_data, st_sirt, ik);              
                end
            end
            
            s = fn_sort(s);

            disp(['p = ', num2str(100*it/ni_t), ', # = ', num2str(ik), ', theta = ', num2str(s(1).x(1), '%5.3f'), ', x = ', num2str(s(1).x(2), '%5.3f'), ', y = ', num2str(s(1).x(3), '%5.3f'), ', error = ', num2str(s(1).ee, '%8.6f')])
            if(norm(s(2).x-s(1).x)<0.1)
                break;
            end      
        end

        txy(ik, :) = txy(ik, :) + s(1).x(2:3);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    astra_mex_algorithm('delete', st_sirt.alg_id);
    astra_mex_data3d('delete', st_sirt.proj_id);    
    astra_mex_data3d('delete', st_sirt.rec_id);
%     astra_mex_data3d('delete', st_sirt.mask_id);  
end

function[s] = fn_shrink(system_conf, s, sigma, st_data, st_sirt, ik_s)
    n_s = length(s);
    x_0 = s(1).x;
    for ik=2:n_s
        x_s = x_0 + sigma*(s(ik).x-x_0);
        s(ik).x = x_s;
        s(ik).ee = fn_get_error(system_conf, st_data, st_sirt, x_s(1), x_s(2:3), ik_s);
    end
end

function[ee] = fn_get_error(system_conf, st_data, st_sirt, theta, txy, ik_s)
    fw_squ_75 = ilc_tr_2d(system_conf, st_data.fw_squ_75, 1, 1, txy*ilm_rot_mat_2d(-theta));

    data_t = st_data.data;        
    n_data = ilm_nz_data(data_t);
    for ik=1:n_data
        im = st_data.data(:, :, ik);
        if(ik==ik_s)
            im = ilc_rot_tr_2d(system_conf, im, 1, 1, theta, st_data.p_rc, st_data.tr(ik, :)+txy, st_data.bg_opt, st_data.bg(ik)); 
            im = im.*fw_squ_75;
        else
            im = ilc_rot_tr_2d(system_conf, im, 1, 1, theta, st_data.p_rc, st_data.tr(ik, :), st_data.bg_opt, st_data.bg(ik)); 
            im = im.*st_data.fw_squ_75;
        end
        data_t(:, :, ik) = im;   
    end 
        
    astra_mex_data3d('store', st_sirt.rec_id, 0);
    astra_mex_data3d('store', st_sirt.proj_id, permute(data_t, [2 3 1]));

    astra_mex_algorithm('iterate', st_sirt.alg_id, st_sirt.n_iter);
    ee = astra_mex_algorithm('get_res_norm', st_sirt.alg_id);
%     ee = round(ee*1e+8)/1e+8;
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