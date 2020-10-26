function [Rx, Ry, R2] = ilm_rs_grid_2d(nx, ny, lx, ly, sft)
    if(nargin<5)
        sft = 1;
    end
    
    if(nargin<3)
        lx = nx;
        ly = ny;
    end
    
    dRx = lx/nx; 
    dRy = ly/ny;
    Rxl = (0:1:(nx-1))*dRx;
    Ryl = (0:1:(ny-1))*dRy;
    
    if(sft==1)
        Rxl = ifftshift(Rxl);
        Ryl = ifftshift(Ryl);
    end    
    
    [Rx, Ry] = meshgrid(Rxl, Ryl);

    if(nargout>2)    
        R2 = Rx.^2 + Ry.^2;
    end
end