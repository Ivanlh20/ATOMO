function[bd] = ilm_set_borders(dr, bd)
    if(nargin<2)
        bd = [0, 0, 0, 0];
    end
    x = dr(1);
    y = dr(2);
    bx_0 = max(0, x);
    by_0 = max(0, y);
    bx_e = max(0, -x);
    by_e = max(0, -y);

    bd = max(bd, [bx_0, bx_e, by_0, by_e]);
end