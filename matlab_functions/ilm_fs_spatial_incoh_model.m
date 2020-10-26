function[y_c] = ilm_fs_spatial_incoh_model(g, coef)
    g2 = g.^2;
    alpha = 2*pi^2*coef(2)^2;
    beta = 4*pi^2*coef(3)^2;
    y_c = coef(1)*exp(-alpha*g2) + (1-coef(1))./(1 + beta*g2).^(3/2);
end