function[idx_xy] = ilm_select_pixels_around(nx, ny, xy, radius)
    [Rx, Ry] = meshgrid(1:nx, 1:ny);
    n_xy = size(xy, 1);
    r2_max = radius^2;
    idx_xy = [];
    for ik=1:n_xy
        ii_t = find((Rx-xy(ik, 1)).^2 + (Ry-xy(ik, 2)).^2<r2_max);
        idx_xy = [idx_xy; ii_t];
    end
end