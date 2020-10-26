function[coef]=ilm_rand_spatial_incoh_coef(coef_0, coef_e)   
    %%%%%%%%%%%%%%%%%% constraints for calculated sigma %%%%%%%%%%%%%%%%%%%
    sigma_c_0 = 0.25;
    sigma_c_e = 2.0;
    
    %%%%%%%%%%%%%%%%%%%%%% constraints for sigma %%%%%%%%%%%%%%%%%%%%%%%%%%
    sigma_0 = sigma_c_0;
    sigma_e = 1.0;
    
    x = 0:0.05:8;
        
    f = 2.00;
    while true
        while true
            coef = ilm_rand(coef_0, coef_e, 1, 3);
            sigma_c = sqrt((2*coef(1)*coef(2)^2 + 6*(1-coef(1))*coef(3)^2)/2);
            pg_max = coef(1)/(2*pi*coef(2)^2);
            pe_max = (1-coef(1))/(2*pi*coef(3)^2);

            if((sigma_c>=sigma_c_0) && (sigma_c<=sigma_c_e) && (pg_max>=f*pe_max))
                break
            end
        end 
        
        y = ilm_rs_spatial_incoh_model(x, coef);
        coef_g = fn_fit_sigma_gaussian_1d_h(y, x);
            
        if((sigma_0<=coef_g(2)) && (coef_g(2)<=sigma_e))
            break;
        end
    end
end
    
function[sigma] = fn_fit_sigma_gaussian_1d_h(y, x)
    x = reshape(x, [], 1);
    y = reshape(y, [], 1);
    
    y_max = max(y);
    coef_0 = [1.0*y_max, 0.5];
    coef_lb = [0.1*y_max, 0.0];
    coef_ub = [1.25*y_max, 4.0];

    options = optimoptions('lsqcurvefit', 'SpecifyObjectiveGradient', true, 'Algorithm', 'trust-region-reflective',...%levenberg-marquardt
    'FunctionTolerance', 1e-10, 'MaxFunctionEvaluation', 2000, 'MaxIterations', 2000, 'Display', 'off');

    sigma = lsqcurvefit(@fn_gaussian_1d_h, coef_0, x, y, coef_lb, coef_ub, options);
end

function[y, J] = fn_gaussian_1d_h(coef, x)
    x2 = x.^2;
    ep = exp(-x2/(2*coef(2)^2));
    y = coef(1)*ep;

    if(nargout > 1)
        J = [ep, coef(1)*ep.*x2/coef(2)^3];
    end
end