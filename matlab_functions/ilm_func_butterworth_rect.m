function[fw, fw_x, fw_y] = ilm_func_butterworth_rect(nx, ny, rect, np_x, np_y)
    if(nargin<5)
        np_y = 16;
    end
    
    if(nargin<4)
        np_x = 16;
    end

    ix_0 = rect(1,1);
    ix_e = rect(2,1);
    radius_x = (ix_e-ix_0)/2+1;

    bd_x = max(0, min(ix_0, nx-ix_e)-1);
    ix_0 = ix_0 - bd_x;
    ix_e = ix_e + bd_x;
    nx_r = ix_e-ix_0+1;

    fw_x = zeros(1, nx);
    fw_x(ix_0:ix_e) = ilc_func_butterworth(nx_r, 1, 1, 1, radius_x, np_x);

    iy_0 = rect(1,2);
    iy_e = rect(2,2);
    radius_y = (iy_e-iy_0)/2+1;

    bd_y = max(0, min(iy_0, ny-iy_e)-1);
    iy_0 = iy_0 - bd_y;
    iy_e = iy_e + bd_y;
    ny_r = iy_e-iy_0+1;

    fw_y = zeros(ny, 1);
    fw_y(iy_0:iy_e) = ilc_func_butterworth(1, ny_r, 1, 1, radius_y, np_y);

    fw = fw_y.*fw_x;
end