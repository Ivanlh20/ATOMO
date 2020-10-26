function [data_o] = ilm_remove_points_fourier_space(data_i, points, Rx, Ry)
    [ny, nx, n_data] = ilm_size_data(data_i);
    if(nargin<3)
        [Rx, Ry] = meshgrid(1:nx, 1:ny);
    end
    x_c = nx/2 + 1;
    y_c = ny/2 + 1;
    n_points = size(points);
    mask = ones(ny, nx);

    for ip=1:n_points
        x_1 = points(ip, 1);
        y_1 = points(ip, 2);
        x_2 = 2*x_c-x_1;
        y_2 = 2*y_c-y_1;
        d = points(ip, 3);
        d2 = d^2;
        alpha = pi/(2*d);
        beta = 0.5*pi;
        R_1 = (Rx-x_1).^2+(Ry-y_1).^2;
        R_2 = (Rx-x_2).^2+(Ry-y_2).^2;
        ii = find(R_1<d2);
        mask(ii) = 1-sin(alpha*sqrt(R_1(ii))+beta).^2;
        ii = find(R_2<d2);
        mask(ii) = 1-sin(alpha*sqrt(R_2(ii))+beta).^2;
    end
    
    mask = ifftshift(mask);
    data_o = data_i;
    for ik=1:n_data
        fim = fft2(ifftshift(data_i(:, :, ik)));
        fim = fim.*mask;
        data_o(:, :, ik) = max(0, real(fftshift(ifft2(fim))));
    end
end
