function[xycg] = ilm_fcc_001_xyc_2_xycg(xyc)
    n_xyc = size(xyc, 1);
    xy = xyc(:, 1:2);
    p_c = xy(1, 1:2);
    idx_g = 1;
    g = 1;
    
    d2 = sum((xy-p_c).^2, 2);
    d2_min = 1.1*min(d2(d2>0.1^2));
    for ik=1:n_xyc
        ik_s = idx_g(ik);
        p_c = xy(ik_s, :);
        d2 = sum((xy-p_c).^2, 2);
        idx = find((d2<d2_min)&(d2>0.1^2));
        idx = setdiff(idx, idx_g);
        if(~isempty(idx))
            b = ~(g(ik)>0.5)*ones(length(idx), 1);
            idx_g = [idx_g; idx];
            g = [g; b];
        end
    end
    g(idx_g) = g;
    xycg = [xyc, g];
end