function[mask_g]=ilm_r_vector_create_mask_gaussian_3d(size_cube, v, par, bb_center)
    if nargin <4
        bb_center = false;
    end
    
    [par.ny, par.nx, par.nz] = ilm_vect_assign(size_cube);
    
    [par.Rx, par.Ry, par.Rz] = meshgrid(single(1:par.nx), single(1:par.ny), single(1:par.nz));

    if(~isfield(par, 'p_c'))
        par.p_c = [par.nx, par.ny, par.nz]/2 + 1;
        if bb_center
            par.p_c = par.p_c  - (0.5*v(1, :) + 0.5*v(2, :) + 0.5*v(3, :));
        end
    end
    
    if(~isfield(par, 'sigma'))
        par.sigma = 2.0;
    end
    
    par.v = v;
    
    par.a = norm(par.v(1, :));
    par.b = norm(par.v(2, :));
    par.c = norm(par.v(3, :));

    lp_min = min([par.a, par.b, par.c]);
    par.r_min = lp_min/2;

    ax = 0:1:par.n_a;
    ay = 0:1:par.n_b;
    az = 0:1:par.n_c;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    xyz_g = zeros((par.n_a+1)*(par.n_b+1)*(par.n_c+1), 3);
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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ng = size(xyz_g, 1);
    data = zeros(ng, 6);
    data(:, 1:3) = xyz_g;
    data(:, 4) = 1;
    data(:, 5) = par.sigma;
    data(:, 6) = 3*par.sigma;

    par.ixyz = ixyz_g;
    par.data = data;
    
    mask_g = ilm_g_ref_create_mask_gaussian_3d(par, true);
end