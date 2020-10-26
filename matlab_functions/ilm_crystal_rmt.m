%%% reciprocal metric tensor
function[g]=ilm_crystal_rmt(a, b, c, alpha, beta, gamma)
    g = ilm_crystal_dmt(a, b, c, alpha, beta, gamma);
    g = inv(g);
end