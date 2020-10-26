function[xyz] = ilm_remove_overlaping_xyz(xyz, radius)
    if (nargin<2)
        radius  = 0.1;
    end
    r2_max = radius^2;
    
    n_xyz = size(xyz, 1);
    bb = ones(n_xyz, 1, 'logical');
    xyz_t = zeros(n_xyz, 3);
    ic = 0;
    for ik=1:n_xyz
        if(bb(ik))
            ic = ic + 1;
            p_c = xyz(ik, :);
            idx = find(sum((xyz-p_c).^2, 2)<r2_max);
            p_c = mean(xyz(idx, :), 1);
            xyz_t(ic, :) = p_c;
            bb(idx) = 0;
        end
    end
    
    xyz = xyz_t(1:ic, :);
end