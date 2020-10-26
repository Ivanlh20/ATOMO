function[Rm] = ilm_rot_mat_3d(theta, u)
    u = u/norm(u);

    theta = theta*pi/180;
    alpha = 1-cos(theta);
    beta = sin(theta);

    Rm = zeros(3,3);
    Rm(1,1) = 1.0 + alpha*(u(1)*u(1)-1);
    Rm(2,1) = u(2)*u(1)*alpha + u(3)*beta;
    Rm(3,1) = u(3)*u(1)*alpha - u(2)*beta;

    Rm(1,2) = u(1)*u(2)*alpha - u(3)*beta;
    Rm(2,2) = 1.0 + alpha*(u(2)*u(2)-1);
    Rm(3,2) = u(3)*u(2)*alpha + u(1)*beta;

    Rm(1,3) = u(1)*u(3)*alpha + u(2)*beta;
    Rm(2,3) = u(2)*u(3)*alpha - u(1)*beta;
    Rm(3,3) = 1.0 + alpha*(u(3)*u(3)-1);
end