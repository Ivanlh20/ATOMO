function[mtf_r] = ilm_eval_rad_mtf(coef, g)
    g2 = g.^2;
    mtf_r = coef(1)*exp(-0.5*g2/coef(2)^2) + (1-coef(1))*exp(-0.5*g2/coef(3)^2);
end