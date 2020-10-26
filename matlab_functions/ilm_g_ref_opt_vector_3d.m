function par = ilm_g_ref_opt_vector_3d(par, cube, n_iter, bb_show)
    if(nargin<4)
        bb_show = false;
    end
    
    if(bb_show)
        options = optimset('PlotFcns', @optimplotfval, 'MaxIter', n_iter);
    else
        options = optimset('MaxIter', n_iter, 'Display', 'off');
    end
    
    idx = (par.Rx-par.p_c(1)).^2 + (par.Ry-par.p_c(2)).^2 + (par.Rz-par.p_c(3)).^2<=par.radius_max^2;
    cube = cube/mean(cube(idx));
    cube(idx) = 0;
    
%     par = ilm_g_ref_opt_iso_sigma_3d(par, cube, 50, false, false);
%     par = ilm_g_ref_opt_iso_A_sigma_3d(par, cube, 50, false, false);
%     par.data(:, 5) = max(par.sigma_min, abs(par.data(:, 5)));
    
    x_0 = reshape(par.v.', [1, 9]);
    x = fminsearch(@(x)fn_chi2_v(x, cube, par), x_0, options);
    par.v = reshape(x, [3, 3]).';
    
    par.data(:, 1:3) = par.p_c + par.ixyz(:, 1).*par.v(1, :) + par.ixyz(:, 2).*par.v(2, :) + par.ixyz(:, 3).*par.v(3, :);
end

function [chi_2]= fn_chi2_v(x, cube, par)
    par.v = reshape(x, [3, 3]).';
    
    ng = size(par.ixyz , 1);
    
    G = zeros(size(cube), 'single');
    for ip=1:ng
        if((ip==par.ip_c)||(abs(par.data(ip, 4))<1e-10))
            continue;
        end
        
        ixyz = par.ixyz(ip, 1:3);
        
        A = par.data(ip, 4);
        sigma = par.data(ip, 5);
        d_max = par.data(ip, 6);
        
        p = par.p_c + ixyz(1)*par.v(1, :) + ixyz(2)*par.v(2, :) + ixyz(3)*par.v(3, :);
        
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
        
        f_ip = A*max(0, exp(-0.5*R2/sigma^2));
        G(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e) = G(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e) + f_ip;
    end
    chi_2 = mean(abs(cube(:) - G(:)));
end