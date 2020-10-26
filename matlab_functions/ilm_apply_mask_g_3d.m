function[cube]=ilm_apply_mask_g_3d(cube, mask_g, f_thr, N, radius)
    if(nargin<5)
       radius = 6;
    end
    
    if(nargin<4)
       N = 2^16;
    end
    
    if(nargin<3)
       f_thr = 0.5;
    end
    
    sc_factor = sum(cube(:));
    [ny, nx, nz]  = size(cube);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     cube = ilm_adapthisteq_3d(cube, N);
    cube = ilm_bg_subtraction_3d(cube, radius); 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fcube = fftn(cube).*ifftshift(mask_g);
    cube = max(0, real(ifftn(fcube)));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     cube = ilm_adapthisteq_3d(cube, N);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cube = cube.*ilm_func_butterworth_3d(nx, ny, nz, 0.95);
    
%     cube = ilm_bg_subtraction_3d(cube, radius); 
    
    cube = ilm_apply_rs_3d_thr(cube, f_thr, false, true);
    cube = cube/max(cube(:));
    
%     cube = cube/max(cube(:));
%     N = 2^19;
%     mask = ilm_get_mask_3d_thr(cube, 1.125)>0;
%     cube(mask) = histeq(cube(mask), N);

    cube = cube*sc_factor/sum(cube(:));
end