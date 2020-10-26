%%% it creates direct space vector in Cartesian coordinates
function[a, b, c]=ilm_crystal_dvect(a, b, c, alpha, beta, gamma)
    g = ilm_crystal_dsm(a, b, c, alpha, beta, gamma);
    v = eye(3)*g;
    if(nargout==1)
        a = v;
    else
        a = v(1, :);
        b = v(2, :);
        c = v(3, :);
    end
end