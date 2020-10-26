function[at_p] = ilm_center_tr_2d_using_at_v(at_p, opt)
    if(nargin<2)
        opt = 1;
    end

    p_c = ilm_get_center_tr_2d(at_p(:, 5:6), opt);

    at_p(:, 5:6) = at_p(:, 5:6)-p_c;
end