function[data] = ilm_tomo_alignment(system_conf, net, fn_list, sigma_g, g_max, bd_p, bb_show_ps, bb_show_ts, rt_opt, bb_first_im, bb_trs)
    if(nargin<11)
        bb_trs = true;
    end
    
    if(nargin<10)
        bb_first_im = false;
    end
    
    if(nargin<9)
        rt_opt = 0;
    end
    
    if(nargin<8)
        bb_show_ts = false;
    end
    
    data = ilm_read_ser_or_dm(fn_list{1});
    [ny, nx, ~] = size(data);
    n_data = numel(fn_list);

    bd_p = [ilm_pn_border(nx, bd_p(1)), ilm_pn_border(ny, bd_p(2))];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    p = 0.05;
    sigma_rt = ilm_sigma_g_2_sigma_r(nx, ny, sigma_g);
    data = zeros(ny, nx, n_data, 'single');
    for ik=1:n_data
        [data_ik_n, n_data_ik_n] = ilm_read_ser_or_dm(fn_list{ik});
        if((n_data_ik_n==1)||bb_first_im)
            im_n = double(data_ik_n(:, :, end));
            if (rt_opt == 0) || (rt_opt>2)
                im_d = im_n;
            elseif rt_opt == 1
                im_d = ilm_nn_stem_data_rt(net, im_n, 0);
            elseif rt_opt == 2
                im_d = ilm_nn_stem_data_rt(net, im_n, 0);
                im_d = ilm_apply_wiener_filter(im_n, im_d, g_max, bd_p);
            end
        else
            data_ik_n = double(data_ik_n);
            data_ik_d = zeros(ny, nx, n_data_ik_n);
            disp('Running time series image restoration ')
            for it =1:n_data_ik_n
                im_n = data_ik_n(:, :, it);
                
                if (rt_opt == 0) || (rt_opt>2)
                    im_d = im_n;
                elseif rt_opt == 1
                    im_d = ilm_nn_stem_data_rt(net, im_n, 0);
                elseif rt_opt == 2
                    im_d = ilm_nn_stem_data_rt(net, im_n, 0);
                    im_d = ilm_apply_wiener_filter(im_n, im_d, g_max, bd_p);
                end

    % im_d = ilm_bandwidth_limit(im_d, g_max, bd_p);
                data_ik_d(:, :, it) = im_d;

                if bb_show_ts
                    figure(1); clf;
                    subplot(1, 2, 1);
                    imagesc(im_n);
                    colormap gray;
                    axis image off;
                    subplot(1, 2, 2);
                    imagesc(im_d);
                    colormap gray;
                    axis image off;
                    title(['# = ', num2str(it), '/', num2str(n_data_ik_n)])
                    pause(0.10);
                end
            end

            at_p = ilm_dflt_at_p(n_data_ik_n);
            bd = [0, 0, 0, 0];
            for it=1:2
                at_p = ilm_fd_tr_2d_bi(system_conf, data_ik_d, p, sigma_g, sigma_rt, bd, at_p, 1);
                at_p = ilm_center_tr_2d_using_at_v(at_p);
                bd = ilm_calc_borders_using_at_v(at_p);
            end

            data_ik_d = ilm_at_2_data(system_conf, data_ik_d, at_p, 3, 0);
            im_d = ilm_mean_data(data_ik_d);
            dxy = ilm_get_jitter_opt_flow(im_d, data_ik_d, 2);
            data_ik_d = ilm_apply_jitter_jitter(data_ik_d, dxy);
            im_d = ilm_mean_data(data_ik_d);
            
            if rt_opt == 3
                im_n = im_d;
                im_d = ilm_nn_stem_data_rt(net, im_n, 0);
            elseif rt_opt == 4
                im_n = im_d;
                im_d = ilm_nn_stem_data_rt(net, im_n, 0);
                im_d = ilm_apply_wiener_filter(im_n, im_d, g_max, bd_p);
            end

    %data_ik_n = ilm_at_2_data(system_conf, data_ik_n, at_p, 3, 0);
    %data_ik_n = ilm_apply_jitter_jitter(data_ik_n, dxy);
    %im_n = ilm_mean_data(data_ik_n);
    % 
    %im_nr = ilm_nn_stem_data_rt(net_x, im_n, 0);
    %im_nr = ilm_bandwidth_limit(im_nr, g_max, bd_p);
    %im_n = 0.925*im_n + 0.075*im_nr;
    % 
    %im_d = ilm_apply_wiener_filter(im_n, im_d, g_max, bd_p);
    %im_d = ilc_repl_bdr(im_d, bd_p, 3, 0);
        end
        
        if bb_trs
            im_n = im_n.';
            im_d = im_d.';
        end
        
        data(:, :, ik) = im_d;
        if(bb_show_ps)
            figure(1); clf;
            subplot(1, 2, 1);
            imagesc(im_n);
            colormap gray;
            axis image off;
            title(num2str(ik))
            subplot(1, 2, 2);
            imagesc(im_d);
            colormap gray;
            axis image off;
            title(num2str(ik))
            pause(0.25);
        end
        
        disp(['percentate = ', num2str(100*ik/n_data, '%3.1f'), ' %']);
    end
end