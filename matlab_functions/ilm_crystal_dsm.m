%%% direct structure metric
%%% it transforms crystal coordinates to Cartesian coordinates.
%%% e1 = a1/|a1|, e2 = e3xe1, e3 = ra3/|ra3|
%%% Marc de Graef pag. 57
function[g]=ilm_crystal_dsm(a, b, c, alpha, beta, gamma)
    cos_alpha = cos(alpha*pi/180);
    cos_beta = cos(beta*pi/180);
    cos_gamma = cos(gamma*pi/180);
    
    sin_gamma = sin(gamma*pi/180);
    
    F_bga = cos_beta*cos_gamma - cos_alpha;
    
    vol2 = a^2*b^2*c^2*(1-cos_alpha^2-cos_beta^2-cos_gamma^2+2*cos_alpha*cos_beta*cos_gamma);
    vol = sqrt(vol2);
    
    g = [a, b*cos_gamma, c*cos_beta;...
        0, b*sin_gamma, -c*F_bga/sin_gamma;...
        0, 0, vol/(a*b*sin_gamma)];
    
    g = g.';
end