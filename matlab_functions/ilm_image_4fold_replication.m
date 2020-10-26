function[im_o] = ilm_image_4fold_replication(im_i, dx_i, dy_i, p_x_h, p_y_h, nx_r, ny_r, dx_o, dy_o)
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
    if(x_i(end)<p_x_h-ee)
       x_i = [x_i, p_x_h]; 
       im_i = [im_i, im_i(:, 1)];
    end
    
    if(y_i(end)<p_y_h-ee)
        y_i = [y_i, p_y_h]; 
       im_i = [im_i; im_i(1, :)];
    end
    [Rx_i, Ry_i] = meshgrid(x_i, y_i);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    x_o = 0:dx_o:(nx_r*2*p_x_h);
    y_o = 0:dy_o:(ny_r*2*p_y_h);
    
    ix_p = floor(x_o/p_x_h);
    x_o_p = x_o - p_x_h*ix_p;
    ii = mod(ix_p, 2)==1;
    x_o_p(ii) = p_x_h - x_o_p(ii);
    
    iy_p = floor(y_o/p_y_h);
    y_o_p = y_o - p_y_h*iy_p;
    ii = mod(iy_p, 2)==1;
    y_o_p(ii) = p_y_h - y_o_p(ii);
    
    [Rx_o, Ry_o] = meshgrid(x_o_p, y_o_p);

%     im_o = griddata(Rx_i(:), Ry_i(:), im_i(:), Rx_o, Ry_o, 'cubic');  
    im_o = interp2(Rx_i, Ry_i, im_i, Rx_o, Ry_o, 'spline'); % there is bug usign interp2
    im_o = max(im_o, 0);
end