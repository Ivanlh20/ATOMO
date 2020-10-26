function[nr_grid] = ilm_run_nr_stem(system_conf, data, bd, alpha, sigma, nr_grid, n_iter_i, n_iter_t, opt)
    if(nargin<9)
        opt = 1;
    end
    [ny, nx, n_data] = ilm_size_data(data); 
    [Rx_i, Ry_i] = meshgrid(0:(nx-1), 0:(ny-1));

    x = round(1+bd(1)):round(nx-bd(2));
    ik_0 = ilm_ifelse(n_data<=2, 2, 1);
    im_r = double(data(:, :, 1));
    for idx_t=1:n_iter_t
        if(n_data>2)
            im_r = ilm_mean_data_nr_grid(system_conf, data, nr_grid);
        end
        for ik=ik_0:n_data             
            tic;
            % calculate optical flow
            [phi_x, phi_y] = ilc_opt_flow(system_conf, im_r, double(data(:, :, ik)), alpha, sigma, n_iter_i, double(nr_grid.x(:, :, ik)), double(nr_grid.y(:, :, ik)));
            phi_x = single(phi_x);
            phi_y = single(phi_y);
            
            if(opt==1)
                % fit constant for phi_y
                nr_grid.x(:, :, ik) = repmat(mean(phi_x(:, x), 2), 1, nx);
                % fit constant for phi_y
                nr_grid.y(:, :, ik) = repmat(mean(phi_y(:, x), 2), 1, nx);
            elseif(opt==2)
                % fit second order polynomial for phi_x
                for iy=1:ny
                    p = polyfit(x, phi_x(iy, x), 1);
                    phi_x(iy, :) = polyval(p, 1:nx);
                end
                nr_grid.x(:, :, ik) = phi_x;
                
                % fit constant for phi_y
                nr_grid.y(:, :, ik) = repmat(mean(phi_y(:, x), 2), 1, nx);  
            elseif(opt==3)
                % fit second order polynomial for phi_x
                for iy=1:ny
                    p = polyfit(x, phi_x(iy, x), 2);
                    phi_x(iy, :) = polyval(p, 1:nx);
                end
                nr_grid.x(:, :, ik) = phi_x;
                
                % fit constant for phi_y
                nr_grid.y(:, :, ik) = repmat(mean(phi_y(:, x), 2), 1, nx);                 
            else
                nr_grid.x(:, :, ik) = phi_x;
                nr_grid.y(:, :, ik) = phi_y;
            end
            t_t = toc;
%             disp(['Iter = ', num2str(idx_t), ' - Image = ', num2str(ik)])
            
            Rx_o = Rx_i + double(nr_grid.x(:, :, ik));
            Ry_o = Ry_i + double(nr_grid.y(:, :, ik));

            im_ik = ilc_interp_rn_2d(system_conf, double(data(:, :, ik)), Rx_o, Ry_o);
            
            im_err = ilm_extract_region_using_bd(im_ik-im_r, bd);
            error = mean(abs(im_err(:)));
            
            disp(['Iter = ', num2str(idx_t), ' - Image = ', num2str(ik), ' - error = ', num2str(error), ' - time =', num2str(t_t)])

%             figure(1); clf;
%             subplot(2, 3, 1);
%             imagesc(im_ik);
%             colormap gray;    
%             axis image off; 
%             
%             subplot(2, 3, 2);
%             imagesc(im_r);
%             colormap gray;    
%             axis image off; 
%             
%             subplot(2, 3, 3);
%             imagesc(im_r);
%             colormap gray;    
%             axis image off; 
%             
%             subplot(2, 3, 4);
%             imagesc(im_err);
%             colormap gray;    
%             axis image off;
%             
%             subplot(2, 3, 5);
%             imagesc(nr_grid.x(:, :, ik));
%             colormap gray;    
%             axis image off; 
%             
%             subplot(2, 3, 6);
%             imagesc(nr_grid.y(:, :, ik));
%             colormap gray;    
%             axis image off;   
%             
%             pause(0.10);
        end
    end
end