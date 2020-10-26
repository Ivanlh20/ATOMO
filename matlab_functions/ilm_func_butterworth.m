function[fbw] = ilm_func_butterworth(nx, ny, n, p_bd, p_dd)
    if(nargin<5)
        p_dd = 0.01;
    end

    bd = round(p_bd*nx);
    bd = bd*ones(1, 4);
    
    dd = round(p_dd*nx);
    
    radius = (nx-2*(bd+dd))/2;
    shift = 0;

    fbw = ilc_func_butterworth(nx, ny, 1, 1, radius, n, shift, bd);
end