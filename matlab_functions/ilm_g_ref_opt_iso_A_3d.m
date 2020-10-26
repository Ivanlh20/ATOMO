function par = ilm_g_ref_opt_iso_A_3d(par, cube, n_iter, bb_show)
    if(nargin<4)
        bb_show = false;
    end
    
    if(bb_show)
        options = optimset('PlotFcns', @optimplotfval, 'MaxIter', n_iter);
    else
        options = optimset('MaxIter', n_iter, 'Display', 'off');
    end
    
    n_data = size(par.data, 1);
    for ip=1:n_data
        p = par.data(ip, :);
        d_max = p(6);
        
        ix_0 = ilm_set_bound(floor(p(1)-d_max), 1, par.nx);
        ix_e = ilm_set_bound(ceil(p(1)+d_max), 1, par.nx);
        
        iy_0 = ilm_set_bound(floor(p(2)-d_max), 1, par.ny);
        iy_e = ilm_set_bound(ceil(p(2)+d_max), 1, par.ny);
        
        iz_0 = ilm_set_bound(floor(p(3)-d_max), 1, par.nz);
        iz_e = ilm_set_bound(ceil(p(3)+d_max), 1, par.nz);

        Rx_ip = par.Rx(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p(1);
        Ry_ip = par.Ry(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p(2);
        Rz_ip = par.Rz(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p(3);
        R2 = Rx_ip.^2 + Ry_ip.^2 + Rz_ip.^2;
        
        x_0 = p(4);
        data_xyz.p = p;
        data_xyz.R2 = R2;
        data_xyz.cube = cube(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e);
        data_xyz.cube = data_xyz.cube - min(data_xyz.cube(:));
        
        x = fminsearch(@(x)fn_chi2_A(x, data_xyz), x_0, options);
        x = max(x_0/2, x(1));
        par.data(ip, 4) = x;
        
        disp(['A opt. p = ', num2str(ip), '/', num2str(n_data), ' - [', num2str(x_0), ', ', num2str(x), ']'])
    end
end

function [chi_2]= fn_chi2_A(x, data)
    A = x;
    sigma = data.p(5);
    G_xyz = A*exp(-0.5*data.R2/sigma^2);
    chi_2 = mean(abs(data.cube(:)-G_xyz(:)));
end