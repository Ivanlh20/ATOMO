function[defocus_depth]=ilm_defocus_depth(E_0, alpha)
    alpha = alpha*1e-3;
    defocus_depth = 1.7*ilc_lambda(E_0)/alpha^2;
end