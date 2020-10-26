%%% it creates reciprocal space vector in Cartesian coordinates
function[ar, br, cr]=ilm_crystal_rvect(a, b, c, alpha, beta, gamma)
    [a, b, c] = ilm_crystal_dvect(a, b, c, alpha, beta, gamma);
    vol = dot(cross(a, b), c);
    ar = cross(b, c)/vol;
    br = cross(c, a)/vol;
    cr = cross(a, b)/vol;
    
    if(nargout==1)
        ar = [ar; br; cr];
    end
end