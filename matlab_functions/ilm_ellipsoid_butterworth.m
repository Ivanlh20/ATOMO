function[mask] = ilm_ellipsoid_butterworth(nx, ny, nz, radius, n)
    if(nargin<2)
        ny = nx;
    end
    
    if(nargin<3)
        nz = nx;
    end
    
    if(nargin<4)
        radius = [nx, ny, nz]/2-1;
    end

    if(nargin<5)
        n = 32;
    end
    
    radius_2 = radius.^2;
    x_c = nx/2+1;
    y_c = ny/2+1;
    z_c = nz/2+1;
    
    [Rx, Ry, Rz] = meshgrid(single(1:nx), single(1:ny), single(1:nz));
    R2 = (Rx-x_c).^2/radius_2(1)+(Ry-y_c).^2/radius_2(2)+(Rz-z_c).^2/radius_2(3);
    
    mask = 1./(1+R2.^n);
end