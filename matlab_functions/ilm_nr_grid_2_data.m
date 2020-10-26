function[data] = ilm_nr_grid_2_data(system_conf, data, nr_grid, bg_opt, bg)
    if(nargin<5)
        bg = 0;
    end
    
    if(nargin<4)
        bg_opt = 1;
    end
    

    [ny, nx, n_data] = size(data);
    [Rx_i, Ry_i] = meshgrid(0:(nx-1), 0:(ny-1));
    
    for ik=1:n_data             
        Rx_o = Rx_i + double(nr_grid.x(:, :, ik));
        Ry_o = Ry_i + double(nr_grid.y(:, :, ik));
        
        image_ik = double(data(:, :, ik));
        image_ik = ilc_interp_rn_2d(system_conf, image_ik, Rx_o, Ry_o, bg_opt, bg);
        data(:, :, ik) = image_ik;
    end
end