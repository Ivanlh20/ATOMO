function[atoms] = ilm_theta_xycg_2_atoms(xycg, theta, c)
    n_col = size(xycg, 1);
    theta = theta*pi/180;
    x_min = min(xycg(:, 1));
    z_min = 0;
    atoms = [];
    for ip = 1:n_col
        n_atoms = xycg(ip, 3);
        I = ones(n_atoms, 1);
        z_s = (xycg(ip, 1)-x_min)*tan(theta)+z_min;
        nd = ilm_ifelse(xycg(ip, 4)>0.5, 0.0, 0.5);
        z = (nd + (0:(n_atoms-1)).')*c + round(z_s/c)*c;
        atoms = [atoms; [79*I, xycg(ip, 1)*I, xycg(ip, 2)*I, z, 0.085*I]];
    end
end