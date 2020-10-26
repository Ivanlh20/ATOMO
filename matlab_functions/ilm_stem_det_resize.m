function[det_r]=ilm_stem_det_resize(det_i, det_dgx, center_px, inner_rad_px, parm)                                      % Radius of inner angle in pixel (read by tia)
    inner_rad = inner_rad_px*det_dgx;
    outer_rad = ilc_mrad_2_rangs(parm.E_0, parm.outer_rad_mrad);     % inner radius measured from the detector image in tia                          % Pixel size of the experimental detector image
    det_dgy = det_dgx;                      

    [det_ny, det_nx] = size(det_i);
    p_c = center_px.*[det_dgx, det_dgy];
    gxl = (0:1:(det_nx-1))*det_dgx - p_c(1);
    gyl = (0:1:(det_ny-1))*det_dgy - p_c(2);
    [det_Rx, det_Ry] = meshgrid(gxl, gyl);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dgx = 1/parm.lx;
    dgy = 1/parm.ly;
    p_c = [parm.nx/2+1, parm.ny/2+1].*[dgx, dgy];
    gxl = (0:1:(parm.nx-1))*dgx - p_c(1);
    gyl = (0:1:(parm.ny-1))*dgy - p_c(2); 
    [Rx, Ry] = meshgrid(gxl, gyl);

    det_r = max(0,interp2(det_Rx, det_Ry, det_i, Rx, Ry, 'spline'));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    R = sqrt(Rx.^2+Ry.^2);
    det_r((R<inner_rad)|(R>=outer_rad)) = 0;
end