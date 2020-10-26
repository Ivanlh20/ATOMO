function[par]=ilm_g_ref_opt_vector_set_par_0(v, d_max_ref, cube)
    [par.ny, par.nx, par.nz] = size(cube);
    
    [par.Rx, par.Ry, par.Rz] = meshgrid(single(1:par.nx), single(1:par.ny), single(1:par.nz));

    par.p_c = [par.nx, par.ny, par.nz]/2 + 1;
    
    par.v = v;
    
    par.a = norm(par.v(1, :));
    par.b = norm(par.v(2, :));
    par.c = norm(par.v(3, :));
    
    lp_min = min([par.a, par.b, par.c]);
    par.radius_max = min(d_max_ref, 0.9*min([par.nx, par.ny, par.nz]/2));
    
    par.w = (par.Rx-par.p_c(1)).^2 + (par.Ry-par.p_c(2)).^2 + (par.Rz-par.p_c(3)).^2;
    par.w = reshape(par.w, [], 1);
    par.w(par.w>par.radius_max^2) = 0;
    par.w = par.w/par.radius_max^2;
    
    par.dc_max = d_max_ref;
    par.d_max = 0.5*lp_min;

    par.sigma = par.d_max/3.5;
    par.sigma_min = 1.5;
    par.f = 3;
    par.sigma_c = par.d_max;
    
    par.n_a = floor(par.radius_max/lp_min);
    par.n_b = par.n_a;
    par.n_c = par.n_b;

    ax = (-par.n_a):1:par.n_a;
    ay = (-par.n_b):1:par.n_b;
    az = (-par.n_c):1:par.n_c;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    xyz_g = zeros((2*par.n_a+1)*(2*par.n_b+1)*(2*par.n_c+1), 3);
    ixyz_g = xyz_g;
    idx = 1;
    for ic = az
        for ib = ay
            for ia = ax
                ixyz_g(idx, :) = [ia, ib, ic];
                xyz_g(idx, :) = par.p_c + ia*par.v(1, :) + ib*par.v(2, :)  + ic*par.v(3, :);
                idx = idx + 1;
            end
        end
    end
    ii = sum((xyz_g-par.p_c).^2, 2)>par.radius_max^2;
    xyz_g(ii, :) = [];
    ixyz_g(ii, :) = [];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ng = size(xyz_g, 1);
    
    ip_c = 1;
    for ip=1:ng
        if(norm(ixyz_g(ip, :))<0.001)
            ip_c = ip;
            break;
        end
    end
    [ixyz_g(1, :), ixyz_g(ip_c, :)] = ilm_swap(ixyz_g(1, :), ixyz_g(ip_c, :));
    [xyz_g(1, :), xyz_g(ip_c, :)] = ilm_swap(xyz_g(1, :), xyz_g(ip_c, :));
    
    d_max_ref = par.sigma;
    data = zeros(ng, 6);
    for ip=1:ng
        p = xyz_g(ip, :);

        ix_0 = ilm_set_bound(floor(p(1)-d_max_ref), 1, par.nx);
        ix_e = ilm_set_bound(ceil(p(1)+d_max_ref), 1, par.nx);
        
        iy_0 = ilm_set_bound(floor(p(2)-d_max_ref), 1, par.ny);
        iy_e = ilm_set_bound(ceil(p(2)+d_max_ref), 1, par.ny);
        
        iz_0 = ilm_set_bound(floor(p(3)-d_max_ref), 1, par.nz);
        iz_e = ilm_set_bound(ceil(p(3)+d_max_ref), 1, par.nz);

        cube_ip = cube(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e);
        
        Rx_ip = par.Rx(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p(1);
        Ry_ip = par.Ry(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p(2);
        Rz_ip = par.Rz(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p(3);

        idx = Rx_ip.^2 + Ry_ip.^2 + Rz_ip.^2<=par.d_max^2;
        cube_s = cube_ip(idx);
        
        if(norm(ixyz_g(ip, :))<0.001)
            par.ip_c = ip;
            A = mean(cube_s);
            sigma = par.d_max;
            data(ip, :) = [p, A, sigma, par.d_max];
        else
            A = mean(cube_s);
            sigma = max(1.5, par.d_max/3.5);
            data(ip, :) = [p, A, sigma, par.d_max];
        end
    end
    par.ixyz = ixyz_g;
    par.data = data;
    
    par.A_max = max(data(:, 2));
end