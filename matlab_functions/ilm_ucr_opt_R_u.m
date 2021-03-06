function par = ilm_ucr_opt_R_u(par, n_iter, bb_show)
    if(nargin<3)
        bb_show = false;
    end
    
    if(bb_show)
        options = optimset('PlotFcns', @optimplotfval, 'MaxIter', n_iter);
    else
        options = optimset('MaxIter', n_iter, 'Display', 'off');
    end
    
    G = zeros(size(par.cube), 'single');
    
    x_0 = reshape(par.R_u(:, 1:3), [], 1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     A = [];
%     b = [];
%     Aeq = [];
%     beq = [];
%     lb = max(-0.0625, x_0 - 0.25);
%     ub = min(1.0625, x_0 + 0.25);
%     options = optimoptions('fmincon', 'Algorithm', 'active-set', 'MaxIterations', 10000, 'FunctionTolerance', 1e-10, 'Display', 'iter');
%     options.OptimalityTolerance = 1e-10;
%     options.FunctionTolerance = 1e-10;
%     options.StepTolerance = 1e-10;
%     options.MaxFunctionEvaluations = 50000;
%     x = fmincon(@(x)fn_chi2_R_u(x, par), x_0, A, b, Aeq, beq, lb, ub, [], options);
%     x = max(lb, min(ub, x));
    
    par.x_min = max(-0.0625, x_0 - 0.25);
    par.x_max = min(1.0625, x_0 + 0.25);
    x = fminsearch(@(x)fn_chi2_R_u(x, par), x_0, options);
%     x = max(par.x_min, min(par.x_max, x));
    par.R_u(:, 1:3) = reshape(x, [], 3);
    par.p_c = par.p_c + par.R_u(1, 1:3)*par.v;
    par.R_u(:, 1:3) = par.R_u(:, 1:3) - par.R_u(1, 1:3);

    function [chi_2]= fn_chi2_R_u(x, par)
%         x = max(par.x_min, min(par.x_max, x));
        
        R_u = reshape(x, [], 3);
        sigma = par.R_u(:, 4);
        d_max = par.R_u(:, 5);
        
        G(:) = 0;
        ic = 1;
        for ip=1:par.n_iR
            p_g = par.p_c + par.iR(ip, :)*par.v;
            for iu = 1:par.n_R_u 
                p = p_g + R_u(iu, 1:3)*par.v;

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
        chi_2 = double(mean(abs(par.cube(:) - G(:))));
    end
end

