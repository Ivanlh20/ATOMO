function[cube_o] = ilm_rot_cube_3d(cube_i, Rx, Ry, Rz, theta, u, p_c)
    [ny, nx, nz] = ilm_size_data(cube_i);
    
    p_c = reshape(p_c, 1, []);
    
    Rm = ilm_rot_mat_3d(theta, u);
    
    Rxyz = [Rx(:)-p_c(1), Ry(:)-p_c(2), Rz(:)-p_c(3)]*Rm + p_c;
    
    Rxyz = max(1, round(Rxyz));
    Rxyz(:, 1) = min(nx, Rxyz(:, 1));
    Rxyz(:, 2) = min(ny, Rxyz(:, 2));
    Rxyz(:, 3) = min(nz, Rxyz(:, 3));
    
%     ii = sub2ind([ny, nx, nz], Rxyz(:, 2), Rxyz(:, 1), Rxyz(:, 3));
    
    cube_min = min(cube_i(:));
    cube_o = interp3(Rx, Ry, Rz, cube_i, Rxyz(:, 1), Rxyz(:, 2), Rxyz(:, 3), 'cubic');
    cube_o = max(cube_min, cube_o);
    cube_o = reshape(cube_o, [ny, nx, nz]);
end