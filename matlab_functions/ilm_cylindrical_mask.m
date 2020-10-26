function[mask] = ilm_cylindrical_mask(nx, ny, nz, radius, opt, pr_c)
    if(nargin<6)
        pr_c = [nx, ny]/2 - 0.5;
    end
    
    if(nargin<5)
        opt = 1;
    end
    
    if(nargin<3)
        nz = nx;
    end
    
    if(nargin<2)
        ny = nx;
    end
    
    if(nargin<4)
        radius = min([nx, ny])/2-1;
    end

    if(opt==1)
        [Rx, Ry, ~] = meshgrid(single(0:(nx-1)), single(0:(ny-1)), single(0:(nz-1)));
        R2 = (Rx-pr_c(1)).^2+(Ry-pr_c(2)).^2;

        mask = zeros(ny, nx, nz, 'single');
        mask(R2<radius^2) = 1;
    else
        mask = ilc_func_butterworth(nx, ny, 1, 1, radius, 16, 0, [0, 0, 0, 0], pr_c);   
        mask = repmat(single(mask), 1, 1, nz);
    end
end