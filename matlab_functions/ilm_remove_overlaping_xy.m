function[xy] = ilm_remove_overlaping_xy(xy, radius)
    if (nargin<2)
        radius  = 0.1;
    end
    r2_max = radius^2;
    
    n_xy = size(xy, 1);
    bb = ones(n_xy, 1, 'logical');
    xy_t = zeros(n_xy, 2);
    ic = 0;
    for ik=1:n_xy
        if(bb(ik))
            ic = ic + 1;
            p_c = xy(ik, :);
            idx = find(sum((xy-p_c).^2, 2)<r2_max);
            p_c = mean(xy(idx, :), 1);
            xy_t(ic, :) = p_c;
            bb(idx) = 0;
        end
    end
    
    xy = xy_t(1:ic, :);
end