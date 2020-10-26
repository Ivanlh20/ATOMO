function[y, J] = ilm_gaussian_2d_fix_pos(coef, x, s_xy)
    n_types = length(s_xy);
    bb = nargout > 1;

    n_data = size(x, 1);
    y = zeros(n_data, 1);
    if(bb)
        J = zeros(n_data, 2*n_types);
    end

    for ik=1:n_types
        ip = 2*(ik-1)+1;
        xy = s_xy(ik).xy.';
        
        r2 = (x(:, 1)-xy(1, :)).^2 + (x(:, 2)-xy(2, :)).^2;
        ep = exp(-r2/(2*coef(ip+1)^2));
        y = y + coef(ip)*sum(ep, 2);

        if(bb)
            J(:, ip) = sum(ep, 2);
            J(:, ip+1) = coef(ip)*sum(ep.*r2, 2)/coef(ip+1)^3;
        end
    end
end