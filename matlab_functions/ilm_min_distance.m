function[d_min] = ilm_min_distance(xyz, p_c)
    n_xyz = size(xyz, 1);
    d_min = sqrt(max(sum((xyz - p_c).^2, 2)));
    for ik=1:(n_xyz-1)
        p_c = xyz(ik, :);
        d = sqrt(min(sum((xyz((ik+1):end, :)-p_c).^2, 2)));
        d = d(1);
        if(d<d_min)
            d_min = d;
        end
    end
end