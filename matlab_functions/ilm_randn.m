function [x] = ilm_randn(xm, xs, x_min, x_max, nr, nc)
    if(nargin<6)
        nc = 1;
    end
    if(nargin<5)
        nr = 1;
    end
      
    x = zeros(nr, nc);
    for ix=1:nc
        for iy=1:nr        
            x_t = xm+xs*randn();
            while((x_min>x_t)||(x_t>x_max))
                x_t = xm+xs*randn();
            end
            x(iy, ix) = x_t;
        end
    end
end