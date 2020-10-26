% convert affine transformation between reference image to consecutive images
function[at_p] = ilm_cvt_at_v_r_2_at_v_bci(at_p)
    n_af = size(at_p, 1);
    at_pb = at_p;

    for ik=2:n_af
        [A_b, txy_b] = ilm_cvt_at_v_2_A_txy(at_pb(ik-1, :));
        [A, txy] = ilm_cvt_at_v_2_A_txy(at_pb(ik, :));

        A_b = inv(A_b);
        A = A_b*A; %#ok<MINV>
        txy = A_b*(txy-txy_b); %#ok<MINV>

        at_p(ik, :) = ilm_cvt_A_txy_2_at_v(A, txy);
    end
%     at_p(1, 5:6) = 0;
end