function[coef] = ilm_fit_gaussian_exp_2d_using_fix_pos(im, Rx, Ry, s_xy, coef_0)
    n_ct = length(s_xy);
    i_max = max(im(:));
    im = im/i_max;
    if(nargin<5)
        coef_0 = repmat([0.99, 0.5, 0.01, 0.5], 1, n_ct);
    end
    coef_lb = repmat([0, 0.10, 0.0, 0.01], 1, n_ct);
    coef_ub = repmat([1.25 2.5, 1.25, 5.0], 1, n_ct);

    x = [Rx(:), Ry(:)];
    y = im(:);
  
    options = optimoptions('lsqcurvefit', 'SpecifyObjectiveGradient', true, 'Algorithm', 'levenberg-marquardt',... %'trust-region-reflective'
    'FunctionTolerance', 1e-6, 'MaxFunctionEvaluation', 2000, 'MaxIterations', 2000, 'Display', 'off');

    coef = lsqcurvefit(@(coef, x)ilm_gaussian_exp_2d_fix_pos(coef, x, s_xy), coef_0, x, y, coef_lb, coef_ub, options);
    coef(1:2:end) = i_max*coef(1:2:end);
end