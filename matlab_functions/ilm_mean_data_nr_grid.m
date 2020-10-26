function[image_av] = ilm_mean_data_nr_grid(system_conf, data, nr_grid, bg_opt, bg)
    if(nargin<5)
        bg = 0;
    end
    
    if(nargin<4)
        bg_opt = 1;
    end
    
    b_st = isstruct(data);
    [ny, nx, n_data] = ilm_size_data(data);
    
    [Rx_i, Ry_i] = meshgrid(0:(nx-1), 0:(ny-1));
    
    image_av = zeros(ny, nx);
    for ik=1:n_data             
        Rx_o = Rx_i + double(nr_grid.x(:, :, ik));
        Ry_o = Ry_i + double(nr_grid.y(:, :, ik));

        image_ik = ilm_extract_data(data, ik, b_st, 'double');
        image_av = image_av + ilc_interp_rn_2d(system_conf, image_ik, Rx_o, Ry_o, bg_opt, bg);
    end    
    image_av = image_av/n_data;
end