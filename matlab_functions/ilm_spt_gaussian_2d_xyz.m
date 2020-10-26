function [data] = ilm_spt_gaussian_2d_xyz(xyz, A, sigma, lx, ly, nx, ny)
    im_x = ilm_spt_gaussian_2d_xy(xyz(:, [2, 3]), A, sigma, lx, ly, nx, ny);
    im_y = ilm_spt_gaussian_2d_xy(xyz(:, [1, 3]), A, sigma, lx, ly, nx, ny);
    im_z = ilm_spt_gaussian_2d_xy(xyz(:, [1, 2]), A, sigma, lx, ly, nx, ny);
    data = cat(3, im_x, im_y, im_z);
end