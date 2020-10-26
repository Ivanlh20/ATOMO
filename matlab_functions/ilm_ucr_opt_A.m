function par = ilm_ucr_opt_A(par, n_iter, bb_show)
    if(nargin<3)
        bb_show = false;
    end
    
    if(bb_show)
        options = optimset('PlotFcns', @optimplotfval, 'MaxIter', n_iter);
    else
        options = optimset('MaxIter', n_iter, 'Display', 'off');
    end
    
    ic = 1;
    n_data = par.n_iR*par.n_R_u;
    for ip=1:par.n_iR
        p = par.p_c + par.iR(ip, :)*par.v;
        for iu = 1:par.n_R_u 
            p_iu = p + par.R_u(iu, 1:3)*par.v;
            
            sigma = par.R_u(iu, 4);
            d_max = par.R_u(iu, 5);
            
            ix_0 = ilm_set_bound(floor(p_iu(1)-d_max), 1, par.nx);
            ix_e = ilm_set_bound(ceil(p_iu(1)+d_max), 1, par.nx);

            iy_0 = ilm_set_bound(floor(p_iu(2)-d_max), 1, par.ny);
            iy_e = ilm_set_bound(ceil(p_iu(2)+d_max), 1, par.ny);

            iz_0 = ilm_set_bound(floor(p_iu(3)-d_max), 1, par.nz);
            iz_e = ilm_set_bound(ceil(p_iu(3)+d_max), 1, par.nz);
            
            Rx_ip = par.Rx(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p_iu(1);
            Ry_ip = par.Ry(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p_iu(2);
            Rz_ip = par.Rz(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p_iu(3);
            R2 = Rx_ip.^2 + Ry_ip.^2 + Rz_ip.^2;
            

            data_A.f = exp(-0.5*R2/sigma^2);
            data_A.cube = par.cube(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e);
            
            x_0 = par.A(ic);
            x = fminsearch(@(x)fn_chi2_A(x, data_A), x_0, options);
            
            idx = R2<=par.r_min^2;
            cube_s = data_A.cube(idx);
            A_min = max(cube_s)/2;
            
            par.A(ic) = max(A_min, x);
            
            disp(['A opt. p = ', num2str(ic), '/', num2str(n_data)])

            ic = ic + 1;
        end
    end
end

function [chi_2]= fn_chi2_A(x, data)
    A = x;
    G_xyz = A*data.f;
    chi_2 = mean(abs(data.cube(:)-G_xyz(:)));
end