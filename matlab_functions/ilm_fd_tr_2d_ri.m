% find shifting between images
function [at_p] = ilm_fd_tr_2d_ri(system_conf, im_r, data, p, sigma_g, bd_0, at_p, n_it, b_fit)
    n_data = ilm_nz_data(data);
    im_r = double(im_r);
    
     if(nargin<9)
        b_fit = true;
     end
    
    if(nargin<8)
        n_it = 1;
    end
    
    if(nargin<7)
        at_p = ilm_dflt_at_p(n_data);
    end
    
    if(nargin<6)
        bd_0 = zeros(1, 4);
    end
    
    dx = 1; 
    dy = 1;
    n_show = min(100, max(1, round(n_data/100)));
    for it = 1:n_it
        tic;
        for ik = 1:n_data
            at_p_ik = at_p(ik, :);
            bd = ilm_set_borders(at_p_ik(5:6), bd_0);
            [A, txy] = ilm_cvt_at_v_2_A_txy(at_p_ik);
            im_ik = double(data(ik).image);
            at_p(ik, 5:6) = ilc_fd_tr_2d(system_conf, im_r, im_ik, dx, dy, A, txy, p, sigma_g, bd, 6, 0, b_fit);

            if(rem(ik, n_show)==0)
                t_c = toc;
                disp(['iter = ', num2str(it), ' calculating shift between ref. image and image #', num2str(ik), '/', num2str(n_data), '_time=', num2str(t_c, '%5.2f')]); 
                tic;
            end
        end
        t_c = toc;
        disp(['iter = ', num2str(it), ' calculating shift between ref. image and image #', num2str(n_data), '/', num2str(n_data), '_time=', num2str(t_c, '%5.2f')]); 
    end
end