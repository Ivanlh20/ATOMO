function[af] = ilm_cvt_A_txy_2_at_v(A, txy)
    af = [reshape(A(:), 1, 4), txy(1), txy(2)];
end