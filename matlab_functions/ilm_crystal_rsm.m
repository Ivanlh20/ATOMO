%%% reciprocal structure metric
%%% it transforms crystal reciprocal coordinates to Cartesian coordinates.
%%% e1 = a1/|a1|, e2 = e3xe1, e3 = ra3/|ra3|
%%% Marc de Graef pag. 58
function[g]=ilm_crystal_rsm(a, b, c, alpha, beta, gamma)
    g = ilm_crystal_dsm(a, b, c, alpha, beta, gamma);
    g = inv(g).';
end