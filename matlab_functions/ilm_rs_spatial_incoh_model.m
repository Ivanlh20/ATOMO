function[y_c] = ilm_rs_spatial_incoh_model(R, coef)
    R2 = R.^2;
    alpha = 0.5/coef(2)^2;
    beta = 1/coef(3);
    y_c = coef(1)*exp(-alpha*R2)/(2*pi*coef(2)^2) + (1-coef(1))*exp(-beta*R)/(2*pi*coef(3)^2);
end