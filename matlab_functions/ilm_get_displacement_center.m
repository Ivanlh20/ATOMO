function [dxy] = ilm_get_displacement_center(data_i, Rx, Ry)
    [ny, nx] = size(data_i(1).image);
    if(nargin<1)
        [Rx, Ry] = meshgrid(1:nx, 1:ny);
    end
    Rx = Rx(:);
    Ry = Ry(:);
    x_c = nx/2 + 1;
    y_c = ny/2 + 1;
    
    n_data = length(data_i);
    dxy = zeros(n_data, 2);
    for ik=1:n_data
        im = data_i(ik).image(:);
        im = im/sum(im);
        dxy(ik, :) = [x_c, y_c]-[sum(Rx.*im), sum(Ry.*im)];
    end
end
