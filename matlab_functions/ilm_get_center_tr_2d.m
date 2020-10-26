function[p_c] = ilm_get_center_tr_2d(xy, opt)
    if(nargin<2)
        opt = 1;
    end
    
    p_c = xy(1, :);
    if(size(xy, 1)>2)
        x = xy(:, 1);
        y = xy(:, 2);
        switch opt
            case 1
                [x_min, x_max] = ilm_min_max(x);
                [y_min, y_max] = ilm_min_max(y);
                p_c = 0.5*[x_max+x_min, y_max+y_min]; 
            case 2
                p_c = mean(xy);
            case 3
                p_c = mean(xy);  
                f_lim = 2.5*std(xy);
                p_c(1) = mean(x(abs(x-p_c(1))<f_lim(1)));
                p_c(2) = mean(y(abs(y-p_c(2))<f_lim(2)));
        end
    end
end
