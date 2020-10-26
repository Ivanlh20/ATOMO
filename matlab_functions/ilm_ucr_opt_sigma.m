function par = ilm_ucr_opt_sigma(par, n_iter, bb_show)
    if(nargin<3)
        bb_show = false;
    end
    
    if(bb_show)
        options = optimset('PlotFcns', @optimplotfval, 'MaxIter', n_iter);
    else
        options = optimset('MaxIter', n_iter, 'Display', 'off');
    end
    
    x_0 = par.R_u(:, 4);
    x = fminsearch(@(x)fn_chi2_sigma(x, par), x_0, options);
    
    x = max(1, min(x, par.r_min*2/3));
    
    par.R_u(:, 4) = x;
    par.R_u(:, 5) = 3.5*x;
    
    function [chi_2]= fn_chi2_sigma(x, par)
        sigma = x;
        d_max = par.R_u(:, 5);

        G = zeros(size(par.cube), 'single');
        ic = 1;
        for ip=1:par.n_iR
            p_g = par.p_c + par.iR(ip, :)*par.v;
            for iu = 1:par.n_R_u 
                p = p_g + par.R_u(iu, 1:3)*par.v;

                ix_0 = ilm_set_bound(floor(p(1)-d_max(iu)), 1, par.nx);
                ix_e = ilm_set_bound(ceil(p(1)+d_max(iu)), 1, par.nx);

                iy_0 = ilm_set_bound(floor(p(2)-d_max(iu)), 1, par.ny);
                iy_e = ilm_set_bound(ceil(p(2)+d_max(iu)), 1, par.ny);

                iz_0 = ilm_set_bound(floor(p(3)-d_max(iu)), 1, par.nz);
                iz_e = ilm_set_bound(ceil(p(3)+d_max(iu)), 1, par.nz);

                Rx_ip = par.Rx(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p(1);
                Ry_ip = par.Ry(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p(2);
                Rz_ip = par.Rz(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e)-p(3);
                R2 = Rx_ip.^2 + Ry_ip.^2 + Rz_ip.^2;

                f_ip = par.A(ic)*max(0, exp(-0.5*R2/sigma(iu)^2));
                G(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e) = G(iy_0:iy_e, ix_0:ix_e, iz_0:iz_e) + f_ip;

                ic = ic + 1;
            end
        end
        chi_2 = mean(abs(par.cube(:) - G(:)));
    end
end

