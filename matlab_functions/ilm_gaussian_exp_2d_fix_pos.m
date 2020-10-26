function[y, J] = ilm_gaussian_exp_2d_fix_pos(coef, x, s_xy)
    n_types = length(s_xy);
    bb = nargout > 1;

    n_data = size(x, 1);
    y = zeros(n_data, 1);
    if(bb)
        J = zeros(n_data, 4*n_types);
    end

    for ik=1:n_types
        ip = 4*(ik-1)+1;
        xy = s_xy(ik).xy.';
        
        r2 = (x(:, 1)-xy(1, :)).^2 + (x(:, 2)-xy(2, :)).^2;
        ep_g = exp(-r2/(2*coef(ip+1)^2));
        
        r = sqrt(r2);
        ep_e = exp(-r/coef(ip+3));
        
        y = y + coef(ip)*sum(ep_g, 2)+ coef(ip+2)*sum(ep_e, 2);

        if(bb)
            J(:, ip) = sum(ep_g, 2);
            J(:, ip+1) = coef(ip)*sum(ep_g.*r2, 2)/coef(ip+1)^3;
            J(:, ip+2) = sum(ep_e, 2);
            J(:, ip+3) = coef(ip+2)*sum(ep_e.*r, 2)/coef(ip+3)^2;
        end
    end
end