% find affine transformation between images
function [at_p] = ilm_fd_tr_scy_shx_2d_bi(system_conf, data, p, sigma_g, bd_0, at_p0, n_it, nit_nm)
    if(isstruct(data))
        disp('Error: The data must be as 3d stack')
        return;
    end
    
    [ny, nx, n_data] = ilm_size_data(data);
    
    if(nargin<8)
        nit_nm = 10;
    end    
    
    if(nargin<7)
        n_it = 1;
    end
    
    if(nargin<6)
        at_p0 = ilm_dflt_at_p(n_data);
    end
    
    if(nargin<5)
        bd_0 = zeros(1, 4);
    end

    % convert affine transformation to consecutive images
    at_p = ilm_cvt_at_v_r_2_at_v_bci(at_p0);
    
    % find affine transformations between images
    dx = 1; 
    dy = 1;  
	bg_opt = 1;
	bg = 0;	
    for it = 1:n_it
        for ik = 2:n_data
            tic;
            at_b = at_p(ik, :);
            bd_t = ilm_at_v_2_bd(nx, ny, bd_0, at_p0(ik-1, :));
            bd_ik = ilm_set_borders(at_b(5:6)); 
            bd = max(bd_t, bd_ik);
            
            at2_b = ilm_cvt_at_v_2_tr_scy_shx_v(at_b);
            at2_a = ilc_fd_tr_scy_shx_2d(system_conf, double(data(:, :, ik-1)), double(data(:, :, ik)), dx, dy, at2_b, p, sigma_g, bd, bg_opt, bg, nit_nm);
            at_p(ik, :) = [at_p(ik, 1:2), at2_a];
            t_c = toc;
            disp(['iter = ', num2str(it), ' calculating shift, scaling-y and shear-x between images #', num2str(ik-1), '_', num2str(ik), '_time=', num2str(t_c, '%5.2f')]);

%             ilm_show_pcf(system_conf, data(:, :, ik-1), data(:, :, ik).image, at_b, at_p(ik, :), p, sigma_g, bd);
        end
    end

    % transform affine transformations related to the reference image   
    at_p = ilm_cvt_at_v_bci_2_at_v_r(at_p);

    % calculate borders
    bd = 0.75*ilm_calc_borders_using_at_v(at_p, 1);
    
    % find shift between images
    at_p = ilm_fd_tr_2d_bi(system_conf, data, p, sigma_g, bd, at_p, 1);
end