function[proj_geom] = ilm_astra_create_parallel3d_proj_geom(nx, ny, angles, theta, txy)
    n_angles = length(angles);
    
    if(nargin<5)
        txy = zeros(n_angles, 2);
    end
    
    if(nargin<4)
        theta = 0;
    end
    
    if(size(txy, 1)==1)
        txy = repmat(txy, n_angles, 1);
    end
    
    cos_theta = cos(theta);
    sin_theta = sin(theta);  
    vectors = zeros(n_angles, 12);
    
    for ik=1:n_angles
        cos_alpha = cos(angles(ik));
        sin_alpha = sin(angles(ik));    
        
        A = [cos_alpha, -sin_alpha, 0; sin_alpha, cos_alpha, 0; 0, 0, 1];
        A = A*[cos_theta 0 sin_theta; 0 1 0; -sin_theta 0 cos_theta];
        x = A*[-txy(ik, 1); 0; -txy(ik, 2)];
        
        vectors(ik, 1:3) = [sin_alpha, -cos_alpha, 0];
        vectors(ik, 4:6) = x(1:3);       
        vectors(ik, 7:9) = [cos_theta*cos_alpha, cos_theta*sin_alpha, -sin_theta];
        vectors(ik, 10:12) = [sin_theta*cos_alpha, sin_theta*sin_alpha, cos_theta];
    end
    
    proj_geom = astra_create_proj_geom('parallel3d_vec', ny, nx, vectors);
end