function [gx, gy, g2] = ilm_fs_grid_2d(nx, ny, lx, ly, sft)
    if(nargin<5)
        sft = 1;
    end
    
    if(nargin<3)
        lx = nx;
        ly = ny;
    end
    
    nxh = nx/2; 
    nyh = ny/2;
    dgx = 1/lx; 
    dgy = 1/ly;
    gxl = (-nxh:1:(nxh-1))*dgx;
    gyl = (-nyh:1:(nyh-1))*dgy;
    
    if(sft==1)
        gxl = ifftshift(gxl);
        gyl = ifftshift(gyl);
    end
    
    [gx, gy] = meshgrid(gxl, gyl);
    
    if(nargout>2)
        g2 = gx.^2 + gy.^2;
    end
end