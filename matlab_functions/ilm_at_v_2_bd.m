function[bd] = ilm_at_v_2_bd(nx, ny, bd, at)
    p = ilm_bd_2_xy(nx, ny, bd)';
    [A, txy] = ilm_cvt_at_v_2_A_txy(at);
    p = A\(p-txy);
    p(1, :) = min(nx, max(0, p(1, :)));
    p(2, :) = min(ny, max(0, p(2, :)));
    
    bd(1) = max(p(1, 1), p(1, 4));
    bd(2) = nx-min(p(1, 2), p(1, 3));
    
    bd(3) = max(p(2, 1), p(2, 2));
    bd(4) = ny-min(p(2, 3), p(2, 4));
end