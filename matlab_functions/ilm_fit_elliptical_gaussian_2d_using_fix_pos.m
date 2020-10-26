function[coef] = ilm_fit_elliptical_gaussian_2d_using_fix_pos(im, Rx, Ry, s_xy, coef_0)
    n_ct = length(s_xy);
    
    if(nargin<5)
        i_max = max(im(:));
        coef_0 = repmat([i_max, 0.5, 0.5], 1, n_ct);
        coef_lb = repmat([0.0, 0.15, 0.15], 1, n_ct);
        coef_ub = repmat([1.25*i_max, 3.0, 3.0], 1, n_ct);
    else
        coef_lb = coef_0*repmat([0.1, 0.1, 0.1], 1, n_ct);
        coef_ub = coef_0.*repmat([2.0, 2.0, 2.0], 1, n_ct);
    end
    
    x = [Rx(:), Ry(:)];
    y = im(:);
  
    options = optimoptions('lsqcurvefit', 'SpecifyObjectiveGradient', true, 'Algorithm', 'levenberg-marquardt',...
    'FunctionTolerance', 1e-10, 'MaxFunctionEvaluation', 2000, 'MaxIterations', 2000, 'Display', 'off');

    coef = lsqcurvefit(@(coef, x)ilm_elliptical_gaussian_2d_fix_pos(coef, x, s_xy), coef_0, x, y, coef_lb, coef_ub, options);
end