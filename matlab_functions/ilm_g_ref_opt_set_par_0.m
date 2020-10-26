function[par]=ilm_g_ref_opt_set_par_0(xyz, d_min, cube)
    [par.ny, par.nx, par.nz] = size(cube);
    
    [par.Rx, par.Ry, par.Rz] = meshgrid(single(1:par.nx), single(1:par.ny), single(1:par.nz));

    par.p_c = [par.nx, par.ny, par.nz]/2 + 1;

    d2 = sort(sum((xyz-par.p_c).^2, 2));
    dc_max = sqrt(d2(2))/2;
    par.dc_max = dc_max;
 
    d_max = d_min/2;
    par.d_max = d_max;
    par.sigma = max(1, d_max/5);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    n_data = size(xyz, 1);
    data = zeros(n_data, 6);
    
    for ip=1:n_data
        p = xyz(ip, :);
        if(isequal(p(1:3), par.p_c))
            par.ip_c = ip;
            break;
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for ip=1:n_data
        p = xyz(ip, :);

        ix_0 = ilm_set_bound(floor(p(1)-par.d_max), 1, par.nx);
        ix_e = ilm_set_bound(ceil(p(1)+par.d_max), 1, par.nx);
        
        iy_0 = ilm_set_bound(floor(p(2)-par.d_max), 1, par.ny);
        iy_e = ilm_set_bound(ceil(p(2)+par.d_max), 1, par.ny);
        
        iz_0 = ilm_set_bound(floor(p(3)-par.d_max), 1, par.nz);
        iz_e = ilm_set_bound(ceil(p(3)+par.d_max), 1, par.nz);

        cube_ip = cube(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e);
        
        Rx_ip = par.Rx(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p(1);
        Ry_ip = par.Ry(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p(2);
        Rz_ip = par.Rz(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p(3);
        
        idx = Rx_ip.^2 + Ry_ip.^2 + Rz_ip.^2<=par.d_max^2;
        cube_s = cube_ip(idx);
        cube_s = cube_s - min(cube_s(:));
        
        if(par.ip_c == ip)
            A = 0.5*(mean(cube_s) + max(cube_s));
            sigma = max(1, d_max);
            data(ip, :) = [p, A, sigma, d_max];
        else
            A = 0.5*(mean(cube_s) + max(cube_s));
            sigma = max(1.5, d_max/5);
            data(ip, :) = [p, A, sigma, d_max];
        end
    end
    par.data = data;
end