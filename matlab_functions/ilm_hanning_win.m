function[f] = ilm_hanning_win(nx, ny, radius, shift, bd)
    if(nargin<5)
        bd = zeros(1, 4);
    end
    
    if(nargin<4)
        shift = 0;
    end
    
    cxy = pi/max(nx-sum(bd(1:2)), ny-sum(bd(3:4)));
    k = cos(cxy*radius)^2;
    f = ilc_func_hanning(nx, ny, 1, 1, k, shift, bd);
end