% find affine transformation using mean image
function [at_p] = ilm_fd_tr_scy_shx_2d_ri(system_conf, data, p, sigma_g, bd_0, at_p0, n_it, nit_nm)
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
     
    dx = 1; 
    dy = 1;
	bg_opt = 1;
	bg = 0;
    
    at_p = at_p0;
    bd = bd_0;
    
    for it = 1:n_it
        % calculated reference image
        image_r = ilm_mean_data_at(system_conf, data, at_p);

        % find affine transformations related to the reference image
        for ik = 1:n_data
            tic;
            at_b = at_p(ik, :);
            at2_b = ilm_cvt_at_v_2_tr_scy_shx_v(at_b);
            at2_a = ilc_fd_tr_scy_shx_2d(system_conf, image_r, double(data(:, :, ik)), dx, dy, at2_b, p, sigma_g, bd, bg_opt, bg, nit_nm);
            at_p(ik, :) = [at_p(ik, 1:2), at2_a];
            t_c = toc;
            disp(['iter = ', num2str(it), ' calculating shift, scaling-y and shear-x between reference image and image #', num2str(ik), '_time=', num2str(t_c, '%5.2f')]); 

%             ilm_show_pcf(system_conf, image_r, data(:, :, ik), at_b, at_p(ik, :), p, sigma_g, bd); 
        end

        % calculate borders
        bd = 0.75*ilm_calc_borders_using_at_v(at_p);  
    end
end