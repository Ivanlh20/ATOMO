function[y, J] = ilm_elliptical_gaussian_2d_fix_pos(coef, x, s_xy)
    n_types = length(s_xy);
    bb = nargout > 1;

    n_data = size(x, 1);
    y = zeros(n_data, 1);
    if(bb)
        J = zeros(n_data, 2*n_types);
    end

    for ik=1:n_types
        ip = 3*(ik-1)+1;
        xy = s_xy(ik).xy.';
        
        r2x = (x(:, 1)-xy(1, :)).^2;
        r2y = (x(:, 2)-xy(2, :)).^2;
        epx = exp(-r2x/(2*coef(ip+1)^2));
        epy = exp(-r2y/(2*coef(ip+1)^2));
        epxy = epx.*epy;
        y = y + coef(ip)*sum(epxy, 2);

        if(bb)
            J(:, ip) = sum(epxy, 2);
            J(:, ip+1) = coef(ip)*sum(epxy.*r2x, 2)/coef(ip+1)^3;
            J(:, ip+2) = coef(ip)*sum(epxy.*r2y, 2)/coef(ip+2)^3;
        end
    end
end