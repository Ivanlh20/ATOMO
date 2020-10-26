function[sigma_r] = ilm_sigma_g_2_sigma_r(lx, ly, sigma_g)
    sigma_r = 1/(2*pi*sigma_g*min(1/lx, 1/ly));
end