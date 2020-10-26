function[mask_g]=ilm_g_ref_vector_create_mask_gaussian_3d(size_cube, v, r_max, f_cb, f_gr)
    if(nargin<5)
        f_gr = 4;
    end
    
    if(nargin<4)
        f_cb = 3;
    end
    
    [par.ny, par.nx, par.nz] = ilm_vect_assign(size_cube);
    
    [par.Rx, par.Ry, par.Rz] = meshgrid(single(1:par.nx), single(1:par.ny), single(1:par.nz));

    par.p_c = [par.nx, par.ny, par.nz]/2 + 1;
    
    par.v = v;
    
    par.a = norm(par.v(1, :));
    par.b = norm(par.v(2, :));
    par.c = norm(par.v(3, :));

    lp_min = min([par.a, par.b, par.c]);
    par.r_min = lp_min/2;
    par.radius_max = min(r_max, 0.9*min([par.nx, par.ny, par.nz]/2));

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

    data = zeros(ng, 6);
    for ip=1:ng
        p = xyz_g(ip, :);
        if(norm(ixyz_g(ip, :))<0.001)
            sigma = max(2.0, par.r_min/f_cb);
            d_max = par.r_min;
        else
            sigma = max(1.0, par.r_min/f_gr);
            d_max = min(4.0*sigma, par.r_min);
        end
        data(ip, :) = [p, 1, sigma, d_max];
    end
    par.ixyz = ixyz_g;
    par.data = data;
    
    mask_g = ilm_g_ref_create_mask_gaussian_3d(par, true);
end