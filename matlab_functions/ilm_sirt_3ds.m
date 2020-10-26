function[rec] = ilm_sirt_3ds(st_data, rec, b_mask)
    % ilm_sirt_3ds - Gives 3D reconstruction of data (set of projections with vertical axis of rotation)
    
    if(nargin<3)
        b_mask = false;
    end
    
    if(nargin<2)
        rec = 0;
    end
    
    [ny, nx, ~] = size(st_data.data);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    proj_geom = astra_create_proj_geom('parallel', 1, nx, st_data.angles);

    vol_geom = astra_create_vol_geom(nx, nx);
    proj_id = astra_create_projector('linear', proj_geom, vol_geom); 

    disp(['Initialization in ', num2str(toc), ' seconds...'])
    
    cfg = astra_struct('SIRT_CUDA');
    cfg.ProjectorId = proj_id;
      
    ny_s = floor(ny/10);
    tic;
    for idx_slice=1:ny
        sinogram = squeeze(st_data.data(idx_slice, :, :));
        sinogram = permute(sinogram, [2, 1]);
        sinogram_id = astra_mex_data2d('create', '-sino', proj_geom, sinogram);
        if(nargin<4)
            rec_id = astra_mex_data2d('create', '-vol', vol_geom, rec);
        else
            rec_id = astra_mex_data2d('create', '-vol', vol_geom, squeeze(rec(:, :, idx_slice)));
        end     
        
        cfg.ReconstructionDataId = rec_id;
        cfg.ProjectionDataId = sinogram_id;
        cfg.option.MinConstraint = 0;

        alg_id = astra_mex_algorithm('create', cfg);
        
        astra_mex_algorithm('iterate', alg_id, n_iter);
        rec(:, :, idx_slice) = astra_mex_data2d('get_single', rec_id);

        astra_mex_algorithm('delete', alg_id)
        astra_mex_data2d('delete', sinogram_id)
        astra_mex_data2d('delete', rec_id);

        if ((rem(idx_slice, ny_s)==0)||(idx_slice==ny))
            disp([num2str(round(idx_slice/ny*100)), '% - ', 'calculated reconstruction for slice ', num2str(idx_slice), ' in ', num2str(toc), ' seconds'])
            tic;
        end
    end  
    
    astra_mex_projector('delete', proj_id);
end