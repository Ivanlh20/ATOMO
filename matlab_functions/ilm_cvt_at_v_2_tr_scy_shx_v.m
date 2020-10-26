% Convert affine transformation vector to translation, scaling-y and
% shear-x vector
function[af_o] = ilm_cvt_at_v_2_tr_scy_shx_v(af_i)
    af_o = [af_i(3), af_i(4), af_i(5), af_i(6)];
end