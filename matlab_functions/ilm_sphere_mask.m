function[mask] = ilm_sphere_mask(nx, ny, nz, radius)
    if(nargin<2)
        ny = nx;
    end
    
    if(nargin<3)
        nz = nx;
    end
    
    if(nargin<4)
        radius = min([nx, ny, nz])/2-1;
    end

    x_c = nx/2+1;
    y_c = ny/2+1;
    z_c = nz/2+1;
    
    [Rx, Ry, Rz] = meshgrid(single(1:nx), single(1:ny), single(1:nz));
    R2 = (Rx-x_c).^2+(Ry-y_c).^2+(Rz-z_c).^2;
    
    mask = zeros(ny, nx, nz, 'single');
    mask(R2<radius^2) = 1;
end