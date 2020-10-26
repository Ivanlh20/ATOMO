% convert affine transformation between consecutive images to reference image
function[at_p] = ilm_cvt_at_v_bci_2_at_v_r(at_p, at_p0)
    if(nargin>1)
        at_p(1, :) = at_p0;
%         [A, txy] = ilm_cvt_at_v_2_A_txy(af_0);
%         A = inv(A);
%         txy = -A*txy;
%         af(1, :) = ilm_cvt_A_txy_2_at_v(A, txy);
    end
    
    n_af = size(at_p, 1);
    [A_b, txy_b] = ilm_cvt_at_v_2_A_txy(at_p(1, :));
    for ik=2:n_af
        [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(ik, :));

        A = A_b*A;        
        txy = A_b*txy + txy_b;
 
        at_p(ik, :) = ilm_cvt_A_txy_2_at_v(A, txy);
        
        A_b = A;
        txy_b = txy;
    end
end