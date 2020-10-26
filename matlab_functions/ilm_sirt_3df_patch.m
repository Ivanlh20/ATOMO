function[rec] = ilm_sirt_3df_patch(st_data, rec, b_mask, n_xyz_0)
    % ilm_sirt_3df - Gives 3D reconstruction of data (set of projections with vertical axis of rotation)
    if(nargin<4)
        n_xyz_0 = 768;
    end

    if(nargin<3)
        b_mask = false;
    end
    
    [nz, nx, n_data] = size(st_data.data);
    ny = nx;
    
    if(nargin<2)
        rec = 0;
    end
    
    if(ndims(rec)~=3)
        rec = rec(1)*ones(nx, ny, nz, 'single');
    end

    n_xyz = nx*ny*nz;
    nz_it = ceil(n_xyz/(n_xyz_0^3));
    [iz_0, iz_e] = ilm_split_range_idx(nz, nz_it, 1);
    nz_block = iz_e-iz_0+1;
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    vol_geom = astra_create_vol_geom(nx, ny, nz_block);
    
    if(isfield(st_data, 'proj_geom'))
        proj_geom = st_data.proj_geom;
    else
        proj_geom = astra_create_proj_geom('parallel3d', 1.0, 1.0, nz_block, nx, st_data.angles);
    end
    
    proj_id = astra_mex_data3d('create', '-proj3d', proj_geom, permute(st_data.data(iz_0:iz_e, :, :), [2 3 1])); % [cols, angles, rows]
    rec_id = astra_mex_data3d('create', '-vol', vol_geom, rec(:, :, iz_0:iz_e));  

    if(b_mask)
        mask_id = astra_mex_data3d('create', '-vol', vol_geom, st_data.mask_cyl(:, :, iz_0:iz_e));
    else
        mask_id = astra_mex_data3d('create', '-vol', vol_geom, 0);
    end
    
    st_sirt = astra_struct('SIRT3D_CUDA');  
    st_sirt.ProjectionDataId = proj_id;
    st_sirt.ReconstructionDataId = rec_id;
    if(b_mask)
        st_sirt.option.ReconstructionMaskId = mask_id; 
    end
    st_sirt.option.MinConstraint = 0;
    
    alg_id = astra_mex_algorithm('create', st_sirt);
    
    st_sirt.alg_id = alg_id;
    st_sirt.proj_id = proj_id;
    st_sirt.rec_id = rec_id;
    if(b_mask)
        st_sirt.mask_id = mask_id;
    end
    st_sirt.n_iter = st_data.n_iter_f;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    astra_mex_algorithm('iterate', st_sirt.alg_id, st_sirt.n_iter);
    rec(:, :, iz_0:iz_e) = astra_mex_data3d('get_single', st_sirt.rec_id);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    if(nz_it>1)
        data_s = zeros(nz_block, nx, n_data, 'single');
        rec_s = zeros(nx, ny, nz_block, 'single');
        if(b_mask)
            mask_cyl_s = zeros(nx, ny, nz_block, 'single');
        end
    end
    
    for iz_t = 2:nz_it
        [iz_0, iz_e] = ilm_split_range_idx(nz, nz_it, iz_t);
        
        data_s(1:(iz_e-iz_0+1), :, :) = st_data.data(iz_0:iz_e, :, :);
        astra_mex_data3d('set', st_sirt.proj_id, permute(data_s, [2 3 1])); % [cols, angles, rows]
        
        rec_s(:, :, 1:(iz_e-iz_0+1)) = rec(:, :, iz_0:iz_e);
        astra_mex_data3d('set', st_sirt.rec_id, rec_s);
        
        if(b_mask)
            mask_cyl_s(:, :, 1:(iz_e-iz_0+1)) = st_data.mask_cyl(:, :, iz_0:iz_e);
            astra_mex_data3d('set', st_sirt.mask_id, mask_cyl_s);
        end
        
        astra_mex_algorithm('iterate', st_sirt.alg_id, st_sirt.n_iter);
        rec_t = astra_mex_data3d('get_single', st_sirt.rec_id);
        rec(:, :, iz_0:iz_e) = rec_t(:, :, 1:(iz_e-iz_0+1));
    end
    
    astra_mex_algorithm('delete', st_sirt.alg_id);
    astra_mex_data3d('delete', st_sirt.proj_id);    
    astra_mex_data3d('delete', st_sirt.rec_id);
    
    if(b_mask)
        astra_mex_data3d('delete', st_sirt.mask_id);
    end
end