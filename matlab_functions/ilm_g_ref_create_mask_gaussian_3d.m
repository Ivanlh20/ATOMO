function[G]=ilm_g_ref_create_mask_gaussian_3d(par, bb_ng)
    if(nargin<2)
        bb_ng = 0;
    end
    
    n_data = size(par.data , 1);
    G = zeros(size(par.Rx), 'single');
    for ip=1:n_data
        p = par.data(ip, 1:3);
        A = par.data(ip, 4);
        sigma = par.data(ip, 5);
        d_max = par.data(ip, 6);
        
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
        
        if(bb_ng)
            f_sft = A*exp(-0.5*d_max^2/sigma^2);
            f_ip = max(0, A*exp(-0.5*R2/sigma^2)-f_sft)/(A-f_sft);
        else
            f_ip = A*exp(-0.5*R2/sigma^2);
        end
        G(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e) = G(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e) + f_ip;
    end
end