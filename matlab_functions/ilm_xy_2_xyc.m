function[xyc] = ilm_xy_2_xyc(xy, radius)
    if (nargin<2)
        radius  = 0.25;
    end
    r2_max = radius^2;
    
    n_xy = size(xy, 1);
    bb = ones(n_xy, 1, 'logical');
    xyc = zeros(n_xy, 3);
    ic = 0;
    for ik=1:n_xy
        if(bb(ik))  
            ic = ic + 1;
            p_c = xy(ik, :);
            idx = find(sum((xy-p_c).^2, 2)<r2_max);
            p_c = mean(xy(idx, :), 1);
            xyc(ic, :) = [p_c, length(idx)];
            bb(idx) = 0;
        end
    end
    
    xyc = xyc(1:ic, :);
end