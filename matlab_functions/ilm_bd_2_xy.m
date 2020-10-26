function[xy] = ilm_bd_2_xy(lx, ly, bd)
    xy = [bd(1), bd(3); lx-bd(2), bd(3); lx-bd(2), ly-bd(4); bd(1), ly-bd(4)];
end