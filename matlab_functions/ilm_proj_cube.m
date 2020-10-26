function [data_p] = ilm_proj_cube(cube, angles)

%     [ny, nx, nz] = size(cube); 
%     vol_geom = astra_create_vol_geom(ny, nx, nz);
%     proj_geom = astra_create_proj_geom('parallel3d', 1.0, 1.0, ny, nx, angles);
%     
%     [proj_id, data_p] = astra_create_sino3d_cuda(cube, proj_geom, vol_geom);
%     data_p = permute(data_p, [3 1 2]);
%     
%     astra_mex_data3d('delete', proj_id);
    
    [ny, nx, nz] = size(cube); 
    vol_geom = astra_create_vol_geom(ny, nx, nz);
    if(isstruct(angles))
        proj_geom = angles;
    else
        proj_geom = astra_create_proj_geom('parallel3d', 1.0, 1.0, nz, nx, angles);
    end
    
    rec_id = astra_mex_data3d('create', '-vol', vol_geom, cube); 
    proj_id = astra_mex_data3d('create', '-sino', proj_geom, 0);

    fp3d = astra_struct('FP3D_CUDA');
    fp3d.ProjectionDataId = proj_id;
    fp3d.VolumeDataId = rec_id;
    
    alg_id = astra_mex_algorithm('create', fp3d);
    
    astra_mex_algorithm('iterate', alg_id);
    
    data_p = astra_mex_data3d('get_single', proj_id);
    data_p = permute(data_p, [3 1 2]);
    
    astra_mex_algorithm('delete', alg_id);
    astra_mex_data3d('delete', rec_id);
    astra_mex_data3d('delete', proj_id);
end