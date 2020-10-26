%%% direct metric tensor
function[g]=ilm_crystal_dmt(a, b, c, alpha, beta, gamma)
    cos_alpha = cos(alpha*pi/180);
    cos_beta = cos(beta*pi/180);
    cos_gamma = cos(gamma*pi/180);
    
    g = [a^2, a*b*cos_gamma, a*c*cos_beta;...
        a*b*cos_gamma, b^2, b*c*cos_alpha;...
        a*c*cos_beta, b*c*cos_alpha, c^2];
    g = g.';
end