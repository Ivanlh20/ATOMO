function[Rm] = ilm_rot_mat_2d(theta)
    theta = theta*pi/180;
    cos_theta = cos(theta);
    sin_theta = sin(theta);
    
    Rm = [cos_theta, -sin_theta; sin_theta, cos_theta];
end