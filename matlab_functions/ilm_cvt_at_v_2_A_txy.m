function[A, txy] = ilm_cvt_at_v_2_A_txy(af)
    A = [af(1) af(3); af(2) af(4)];
    txy = [af(5); af(6)];
end