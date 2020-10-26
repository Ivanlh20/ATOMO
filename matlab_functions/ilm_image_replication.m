function[im_o] = ilm_image_replication(im_i, dx_i, dy_i, p_x, p_y, nx_r, ny_r, dx_o, dy_o)
    if(nargin<9)
        dx_o = dx_i;
        dy_o = dy_i;
    end
    
    if(nargin<7)
        ny_r = nx_r;
    end  
    
    if(nargin<6)
        nx_r = 1;
        ny_r = 1;
    end  
    
    [ny, nx] = size(im_i);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    x_i = (0:1:(nx-1))*dx_i;
    y_i = (0:1:(ny-1))*dy_i;

    ee = 1e-4;
    
    if(x_i(end)<p_x-ee)
       x_i = [x_i, p_x]; 
       im_i = [im_i, im_i(:, 1)];
    end
    if(y_i(end)<p_y-ee)
        y_i = [y_i, p_y]; 
       im_i = [im_i; im_i(1, :)];
    end
    [Rx_i, Ry_i] = meshgrid(x_i, y_i);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    x_o = 0:dx_o:(nx_r*p_x);
    y_o = 0:dy_o:(ny_r*p_y);
    x_o_p = x_o - p_x*floor(x_o/p_x);
    y_o_p = y_o - p_y*floor(y_o/p_y);
    
    [Rx_o, Ry_o] = meshgrid(x_o_p, y_o_p);

    im_o = griddata(Rx_i(:), Ry_i(:), im_i(:), Rx_o, Ry_o, 'cubic');  
%     im_n = interp2(Rx_i, Ry_i, im, Rx_o, Ry_o, 'spline'); % there is bug usign interp2
end