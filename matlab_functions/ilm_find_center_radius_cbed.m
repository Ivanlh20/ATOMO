function[p_c, radius] = ilm_find_center_radius_cbed(cbed)
    cbed_b = max(0, ilc_gauss_cv_2d(cbed, 1, 1, 1.0));
    cbed_b = cbed_b/max(cbed_b(:));
    cbed_b = double(cbed_b>0.5);
    [Rx, Ry] = meshgrid(1:nx, 1:ny);
    cbed_sum = sum(cbed_b(:));
    radius = sqrt(cbed_sum/pi);
    p_c = [sum(cbed_b(:).*Rx(:)), sum(cbed_b(:).*Ry(:))]/cbed_sum;

    x_0 = [p_c(1), p_c(2), radius, radius];
    par_i.dp_xy = dp_xy;
    par_i.cbed_mean = cbed_mean;
    par_i.radius = radius;
    par_i.p_c = p_c;
end