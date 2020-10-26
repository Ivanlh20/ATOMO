function[im_r] = ilm_extract_region_using_bd(im_i, bd)
    [ny_i, nx_i] = size(im_i);
    ix_0 = round(1 + bd(1));
    ix_e = round(nx_i - bd(2));
    iy_0 = round(1 + bd(3));
    iy_e = round(ny_i - bd(4));
    im_r = im_i(iy_0:iy_e, ix_0:ix_e);
end