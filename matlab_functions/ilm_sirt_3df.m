function[rec, ee] = ilm_sirt_3df(st_data, rec, b_mask, opt)
    % ilm_sirt_3df - Gives 3D reconstruction of data (set of projections with vertical axis of rotation)
    
    if(nargin<4)
        opt = 1;
    end
    
    if(nargin<3)
        b_mask = false;
    end
    
    if(nargin<2)
        rec = 0;
    end

    [ny, nx, ~] = size(st_data.data);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    vol_geom = astra_create_vol_geom(nx, nx, ny);
    if(isfield(st_data, 'proj_geom'))
        proj_geom = st_data.proj_geom;
    else
        proj_geom = astra_create_proj_geom('parallel3d', 1.0, 1.0, ny, nx, st_data.angles);
    end
    
    % id = astra_mex_data3d('create', '-proj3d', proj_geom, initializer);
    % This creates an initialized 3D projection data object for the geometry proj_geom.
    % Initializer may be:
    % a scalar: the object is initialized with this constant value.
    % a matrix: the object is initialized with the contents of this matrix. 
    % The matrix must be of size (u,angles,v), where u is the number of 
    % columns of the detector and v the number of rows as defined in the 
    % projection geometry. It must be of class single, double or logical.
    % If an initializer is not present, the volume is initialized to zero.

    proj_id = astra_mex_data3d('create', '-proj3d', proj_geom, permute(st_data.data, [2 3 1]));
    rec_id = astra_mex_data3d('create', '-vol', vol_geom, rec);  
    if(b_mask)
        mask_id = astra_mex_data3d('create', '-vol', vol_geom, st_data.vol_mask);
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
    
    astra_mex_algorithm('iterate', st_sirt.alg_id, st_sirt.n_iter);
    switch opt
        case 1
            rec = astra_mex_data3d('get_single', st_sirt.rec_id);
        case 2
            rec = astra_mex_algorithm('get_res_norm', st_sirt.alg_id);
        otherwise
            rec = astra_mex_data3d('get_single', st_sirt.rec_id);
            ee = astra_mex_algorithm('get_res_norm', st_sirt.alg_id);
    end
    
    astra_mex_algorithm('delete', st_sirt.alg_id);
    astra_mex_data3d('delete', st_sirt.proj_id);    
    astra_mex_data3d('delete', st_sirt.rec_id);
    if(b_mask)
        astra_mex_data3d('delete', st_sirt.mask_id);
    end
end