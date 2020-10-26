function[bd] = ilm_calc_borders_using_at_v(at_p, bd)
    if(nargin<2)
        bd = [0, 0, 0, 0];
    end
    
    x = [at_p(:, 5); 0];
    bx_0 = abs(max(x));
    bx_e = abs(min(x));
    
    y = [at_p(:, 6); 0];
    by_0 = abs(max(y));
    by_e = abs(min(y));

    bd = max(bd, [bx_0, bx_e, by_0, by_e]);
end