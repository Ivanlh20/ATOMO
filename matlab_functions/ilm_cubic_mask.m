function[mask] = ilm_cubic_mask(nx, ny, nz, side)
    if(nargin<2)
        ny = nx;
    end
    
    if(nargin<3)
        nz = nx;
    end
    
    if(nargin<4)
        side = min([nx, ny, nz]);
    end
    side = floor(min([nx, ny, nz, side]));
    
    bd = floor((nx-side)/2)+1;
    x = zeros(nx, 1, 1); 
    x(bd:(bd+side-1)) = 1;
    
    bd = floor((ny-side)/2)+1;
    y = zeros(1, ny, 1); 
    y(bd:(bd+side-1)) = 1;
    
    bd = floor((nz-side)/2)+1;
    z = zeros(1, 1, nz); 
    z(bd:(bd+side-1)) = 1;
    
    mask = x.*y.*z;
end