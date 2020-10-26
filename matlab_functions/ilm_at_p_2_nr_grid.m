 function[nr_grid] = ilm_at_p_2_nr_grid(at_p, nx, ny)
    n_at_p = size(at_p, 1);
    [Rx_i, Ry_i] = meshgrid(0:(nx-1), 0:(ny-1));
    Rxy_at = [Rx_i(:), Ry_i(:)]';
    
    nr_grid.x = zeros(ny, nx, n_at_p, 'single');
    nr_grid.y = zeros(ny, nx, n_at_p, 'single');
    
    for ik=1:n_at_p
        [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(ik, :));
        A_i = inv(A);
        txy_i = -A_i*txy;
        Rxy = A_i*Rxy_at + txy_i;
        fx = reshape(Rxy(1, :), ny, nx) - Rx_i;
        fy = reshape(Rxy(2, :), ny, nx) - Ry_i;
        nr_grid.x(:, :, ik) = single(fx);
        nr_grid.y(:, :, ik) = single(fy);        
    end
 end