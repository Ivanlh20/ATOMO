function[par]=ilm_ucr_opt_set_par_0(cube, v, p_c, iR, R_u, sigma_sg)
    [par.ny, par.nx, par.nz] = size(cube);
    
    [par.Rx, par.Ry, par.Rz] = meshgrid(single(1:par.nx), single(1:par.ny), single(1:par.nz));

    par.p_c = p_c;
    
    par.v = v;

    par.r_min = ilc_min_dist(R_u*v)/2;
    par.sigma = max(1, par.r_min/4);
    par.f = 3;
    
    sigma = par.sigma*ones(size(R_u, 1), 1);
    d_max = 3.5*sigma;
    par.R_u = [R_u, sigma, d_max];
    par.n_R_u = size(par.R_u, 1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    par.iR = iR;
    par.n_iR = size(iR, 1);
    n_iRT = par.n_iR*par.n_R_u;
    
    A = zeros(n_iRT, 1);
    d_max_sg = 3.5*sigma_sg;

    G = zeros(size(cube), 'single');
    ic = 1;
    for ip=1:par.n_iR
        p_g = iR(ip, :)*v  + p_c;
        for iu = 1:par.n_R_u 
            p = p_g + par.R_u(iu, 1:3)*v;
            ix_0 = ilm_set_bound(floor(p(1)-par.r_min), 1, par.nx);
            ix_e = ilm_set_bound(ceil(p(1)+par.r_min), 1, par.nx);

            iy_0 = ilm_set_bound(floor(p(2)-par.r_min), 1, par.ny);
            iy_e = ilm_set_bound(ceil(p(2)+par.r_min), 1, par.ny);

            iz_0 = ilm_set_bound(floor(p(3)-par.r_min), 1, par.nz);
            iz_e = ilm_set_bound(ceil(p(3)+par.r_min), 1, par.nz);

            cube_ip = cube(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e);

            Rx_ip = par.Rx(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p(1);
            Ry_ip = par.Ry(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p(2);
            Rz_ip = par.Rz(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p(3);
            R2 = Rx_ip.^2 + Ry_ip.^2 + Rz_ip.^2;
            
            idx = R2<=par.r_min^2;
            cube_s = cube_ip(idx);
            A(ic) = max(cube_s);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ix_0 = ilm_set_bound(floor(p(1)-d_max_sg), 1, par.nx);
            ix_e = ilm_set_bound(ceil(p(1)+d_max_sg), 1, par.nx);

            iy_0 = ilm_set_bound(floor(p(2)-d_max_sg), 1, par.ny);
            iy_e = ilm_set_bound(ceil(p(2)+d_max_sg), 1, par.ny);

            iz_0 = ilm_set_bound(floor(p(3)-d_max_sg), 1, par.nz);
            iz_e = ilm_set_bound(ceil(p(3)+d_max_sg), 1, par.nz);

            Rx_ip = par.Rx(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p(1);
            Ry_ip = par.Ry(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p(2);
            Rz_ip = par.Rz(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p(3);
            R2 = Rx_ip.^2 + Ry_ip.^2 + Rz_ip.^2;
            
            f_ip = max(0, exp(-0.5*R2/sigma_sg^2));
            G(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e) = G(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e) + f_ip;

            ic = ic + 1;
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    par.A = A;
    par.cube = cube;
    idx = find(G>0);
    cube_min = min(par.cube(idx));
    par.cube = par.cube.*(G>0);
    par.cube = max(0, par.cube-cube_min);
    par.cube = par.cube/max(par.cube(idx));
%     N = 2^19;
%     par.cube(idx) = histeq(par.cube(idx), N);
%     par.cube(idx) = sqrt(par.cube(idx));
%     par.cube = par.cube/max(par.cube(idx));
%     par.cube(idx) = histeq(par.cube(idx), N);
end