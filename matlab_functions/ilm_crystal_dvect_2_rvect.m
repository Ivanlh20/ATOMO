%%% it creates reciprocal space vector in Cartesian coordinates
function[ar, br, cr]=ilm_crystal_dvect_2_rvect(a, b, c)
    if(nargin==1)
        c = a(3, :);
        b = a(2, :);
        a = a(1, :);
    end
    
    vol = dot(cross(a, b), c);
    ar = cross(b, c)/vol;
    br = cross(c, a)/vol;
    cr = cross(a, b)/vol;
    
    if(nargout==1)
        ar = [ar; br; cr];
    end
end