function[im_o] = ilm_apply_tr_bw_mask(system_conf, im_i, txy, p_radius, n)
    if(nargin<3)
        n = 4;
    end
    
    [ny, nx] = size(im_i);
    
    radius = round(nx*p_radius);
    bd = round((nx - radius)/2);    
    radius = nx - 2*bd;
    shift = 0;
    bd = bd*ones(1, 4);
    dx = 1;
    dy = 1;
    f_h = ilc_func_butterworth(nx, ny, dx, dy, radius, n, shift, bd);
    A = [1, 0; 0 1];
    im_o = ilc_tr_at_2d(system_conf, im_i, dx, dy, A, txy).*f_h;    
end