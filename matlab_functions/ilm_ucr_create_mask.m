function[G]=ilm_ucr_create_mask(par)
    sigma = par.R_u(:, 4);
    v = par.v;
    r_min = 1.5*par.r_min;
    G = zeros(size(par.Rx), 'single');
    ic = 1;
    for ip=1:par.n_iR
        p = par.p_c + par.iR(ip, :)*v;
        for iu = 1:par.n_R_u 
            p_iu = p + par.R_u(iu, 1:3)*v;
            
            ix_0 = ilm_set_bound(floor(p_iu(1)-r_min), 1, par.nx);
            ix_e = ilm_set_bound(ceil(p_iu(1)+r_min), 1, par.nx);

            iy_0 = ilm_set_bound(floor(p_iu(2)-r_min), 1, par.ny);
            iy_e = ilm_set_bound(ceil(p_iu(2)+r_min), 1, par.ny);

            iz_0 = ilm_set_bound(floor(p_iu(3)-r_min), 1, par.nz);
            iz_e = ilm_set_bound(ceil(p_iu(3)+r_min), 1, par.nz);

            Rx_ip = par.Rx(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p_iu(1);
            Ry_ip = par.Ry(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p_iu(2);
            Rz_ip = par.Rz(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p_iu(3);
            R2 = Rx_ip.^2 + Ry_ip.^2 + Rz_ip.^2;

            f_ip = par.A(ic)*max(0, exp(-0.5*R2/sigma(iu)^2));
            G(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e) = G(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e) + f_ip;

            ic = ic + 1;
        end
    end
end