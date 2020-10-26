function[data, nr_grid, at_p] = ilm_gui_stem_registration(system_conf, data_i, at_p0)
    global n_data nx ny x_c y_c sigma_g_max bd p
    global b_break fz_t bb_nr;
    
    close all
    b_break = false;
    bb_nr = false;
    
    data = data_i;
    [ny, nx, n_data] = ilm_size_data(data); 
    
    fn_set_nr_grid_0(n_data, nx, ny);
    
    if(nargin<3)
        at_p0 = ilm_dflt_at_p(n_data);
    end
    
    at_p = at_p0;
    bd = ilm_calc_borders_using_at_v(at_p);
    p = 0.05; 

    x_c = nx/2 + 1;
    y_c = ny/2 + 1;
    sigma_g_max = min(nx/2, ny/2)-1;
    
    fy = 0.60;
    fx = 0.75;
    dm = get(0, 'MonitorPositions');
    dm = dm(1, :);
    w = fx*dm(3);
    h = fy*dm(4);
    x0 = (1-fx)*w/2;
    y0 = (1-fy)*h/2;

    fh = figure(1); clf;
    set(fh, {'Name', 'Visible', 'units', 'position', 'CloseRequestFcn'}, {'STEM registration -- Software created by Ivan Lobato: Ivanlh20@gmail.com', 'on', 'pixels',[x0, y0, x0+w, y0+h], @cb_close})
    movegui(fh, 'center');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ui_pn_opt = uipanel('Parent', fh, 'Title', 'Options', 'Units', 'normalized',...,
    'FontSize', 12, 'BackgroundColor', 'white', 'Position', [0.425 0.675 0.525 0.25]);

    pn_x_0 = 12;
    pn_y_1 = 120;
    pn_y_2 = 70;
    pn_y_3 = 20;
    pn_w_0 = 90;
    pn_d = 4;    
    pn_h = 24;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pn_n = 12;    
    pn_w = pn_w_0*ones(1, pn_n);
    pn_x = pn_x_0*ones(1, pn_n);
    
    pn_w([5:10]) = [35, 35, 35, 45, 35, 45];
    pn_w(11) = 60;
    
    for ik=2:pn_n
        pn_x(ik) = pn_x(ik-1) + pn_d + pn_w(ik-1);
    end
    
    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Reset txy', 'Position', [pn_x(1) pn_y_1 pn_w(1) pn_h], 'Callback', @cb_reset_txy); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Reset A', 'Position', [pn_x(2) pn_y_1 pn_w(2) pn_h], 'Callback', @cb_reset_A); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'Crt. txy', 'Position', [pn_x(3) pn_y_1 pn_w(3) pn_h], 'Callback', @cb_crt_txy); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'Crt. A_txy', 'Position', [pn_x(4) pn_y_1 pn_w(4) pn_h], 'Callback', @cb_crt_A_txy); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'n_it', 'Position', [pn_x(5) pn_y_1 pn_w(5) pn_h]);
    
    ui_edt_rg_n_it = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '1', 'Position', [pn_x(6) pn_y_1 pn_w(6) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'x_0', 'Position', [pn_x(7) pn_y_1 pn_w(7) pn_h]);
    
    ui_edt_x0 = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.00', 'Position', [pn_x(8) pn_y_1 pn_w(8) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'y_0', 'Position', [pn_x(9) pn_y_1 pn_w(9) pn_h]);
    
    ui_edt_y0 = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.00', 'Position', [pn_x(10) pn_y_1 pn_w(10) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'set txy_0', 'Position', [pn_x(11) pn_y_1 pn_w(11) pn_h], 'Callback', @cb_apply_txy); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Show data', 'Position', [pn_x(12) pn_y_1 pn_w(12) pn_h], 'Callback', @cb_show_rg_data); 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pn_n = 11;    
    pn_w = pn_w_0*ones(1, pn_n);
    pn_x = pn_x_0*ones(1, pn_n);
    
    pn_w(3:9) = [45, 55, 45, 55, 60, 60, 60];
        
    for ik=2:pn_n
        pn_x(ik) = pn_x(ik-1) + pn_d + pn_w(ik-1);
    end  
    
    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Assign A-txy', 'Position', [pn_x(1) pn_y_2 pn_w(1) pn_h], 'Callback', @cb_assign_A_txy); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'Crt. nr_grid', 'Position', [pn_x(2) pn_y_2 pn_w(2) pn_h], 'Callback', @cb_crt_nr_grid); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'n_it_i', 'Position', [pn_x(3) pn_y_2 pn_w(3) pn_h]);
    
    ui_edt_nrg_n_it_i = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '10', 'Position', [pn_x(4) pn_y_2 pn_w(4) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'n_it_o', 'Position', [pn_x(5) pn_y_2 pn_w(5) pn_h]);
    
    ui_edt_nrg_n_it_o = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '8', 'Position', [pn_x(6) pn_y_2 pn_w(6) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'alpha', 'Position', [pn_x(7) pn_y_2 pn_w(7) pn_h]);
    
    ui_edt_alpha = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.5', 'Position', [pn_x(8) pn_y_2 pn_w(8) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'Opt.', 'Position', [pn_x(9) pn_y_2 pn_w(9) pn_h]);
    
    ui_pp_opt = uicontrol('Parent', ui_pn_opt, 'Style', 'popup',... 
    'String', {'Mean', 'Poly 1', 'Poly 2', 'orig.'}, 'Position', [pn_x(10) pn_y_2 pn_w(10) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Show data', 'Position', [pn_x(11) pn_y_2 pn_w(11) pn_h], 'Callback', @cb_show_nr_data); 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pn_n = 9;    
    pn_w = pn_w_0*ones(1, pn_n);
    pn_x = pn_x_0*ones(1, pn_n);
    pn_w(3:2:5) = 60;
    
    for ik=2:pn_n
        pn_x(ik) = pn_x(ik-1) + pn_d + pn_w(ik-1);
    end 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Reset data', 'Position', [pn_x(1) pn_y_3 pn_w(1) pn_h], 'Callback', @cb_reset_data);
    
    uicontrol('Parent', ui_pn_opt, 'Style', 'text',...
    'String', 'Sigma_g(px.)', 'Position', [pn_x(2) pn_y_3 pn_w(2) pn_h]);
    
    ui_edt_sigma = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',...
    'String', num2str(sigma_g_max/2, '%5.2f'), 'Position', [pn_x(3) pn_y_3 pn_w(3) pn_h]); 
    
    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'Time(s.)', 'Position', [pn_x(4) pn_y_3 pn_w(4) pn_h]);
    
    ui_edt_time = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.075', 'Position', [pn_x(5) pn_y_3 pn_w(5) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Show rg. image', 'Position', [pn_x(6) pn_y_3 pn_w(6) pn_h], 'Callback', @cb_show_rg_av_image); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Show nrg. image', 'Position', [pn_x(7) pn_y_3 pn_w(7) pn_h], 'Callback', @cb_show_nrg_av_image); 

    ui_txt_msg = uicontrol('Parent', ui_pn_opt, 'Style', 'text',...
    'String', '00.0%', 'Position', [pn_x(8) pn_y_3 pn_w(8) pn_h], 'FontSize', 13, 'FontWeight', 'bold');  

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'Close', 'Position', [pn_x(9) pn_y_3 pn_w(9) pn_h], 'Callback', @cb_close);  

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    d_f = 0.010;    
    h_f = 0.5;    
    w_1 = 0.16;
    w_2 = h_f*h/w;
    w_3 = w_2;
    w_4 = w_3;
  
    x_1 = (1-(w_1+w_2+w_3+w_4+3*d_f))/2;  
    x_2 = x_1+w_1+d_f;
    x_3 = x_2+w_2+d_f;
    x_4 = x_3+w_3+d_f;    
    y_0 = 0.05;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ui_lb_data = uicontrol('Style', 'listbox', 'Units', 'normalized',...
        'Position', [x_1 y_0 w_1 h_f], 'Callback', @cb_lb_data);
    
    ax_f(1) = axes('Position', [x_2 y_0 w_2 h_f], 'Visible', 'off'); 
    ax_f(2) = axes('Position', [x_3 y_0 w_3 h_f], 'Visible', 'off'); 
    ax_f(3) = axes('Position', [x_4 y_0 w_4 h_f], 'Visible', 'off'); 
    
    fh.WindowButtonMotionFcn = @cb_mouse_move;
    fh.WindowButtonDownFcn = @cb_mouse_click;
    fh.WindowScrollWheelFcn = @cb_zoom_fimage;
    fh.WindowKeyPressFcn = @cb_press_key;

    % set initial sigma
    fimage = ilm_mean_abs_fdata_at(system_conf, data, at_p);
    sigma_gt = ilc_info_limit_2d(fimage);
    ui_edt_sigma.String = num2str(sigma_gt, '%5.2f');
    
    % set initial zoom    
    fz_t(1) = sigma_g_max/(2*ilc_info_limit_2d(fimage));
    fz_t(2) = 1;
    fz_t(3) = sigma_g_max/min(sigma_g_max/2, max(sigma_g_max/5, 6*ilm_sigma_g_2_sigma_r(nx, ny, sigma_gt)));
    
    % plot fimage
    fn_show_ax_f_1(false);

    % set initial lb_data values
    fn_set_lb_data_0(n_data);
    ui_lb_data.Value = 1;
    cb_lb_data();
    
    uiwait(fh)
    
    function fn_msn_start()
        ui_txt_msg.String = 'Processing';
        drawnow;
    end
 
    function fn_msn_end()
        ui_txt_msg.String = 'Done';
        drawnow;
    end

    function fn_show_ax_f_1(b_fimage_rc)
        if(nargin==0)
            b_fimage_rc = true;
        end
        
        if(b_fimage_rc)
            fimage = ilm_mean_abs_fdata_at(system_conf, data, at_p);
        end
        
        % set axes
        axes(ax_f(1));
        
        % plot fimage
        imagesc(fn_rescale_img(fimage));      
        axis image off;
        colormap jet; 

        % plot circle
        sigma_gt = str2double(ui_edt_sigma.String);
        ilm_plot_circle(x_c, y_c, sigma_gt, 'red'); 
        
        zoom(fz_t(1));
    end

    function fn_set_lb_data_0(n_data)
        items{1, n_data} = [];
        UserData{1, n_data} = [];
        for ik=1:n_data
            s_at_p_ik = ['[', num2str(at_p(ik, 3), '%4.3f'), ', ', num2str(at_p(ik, 4), '%4.3f'),...
                ', ', num2str(at_p(ik, 5), '%5.2f'), ', ', num2str(at_p(ik, 6), '%5.2f'), ']'];

            items{ik} = ['ik = ', num2str(ik, '%.3d'), ', at_p = ' s_at_p_ik]; 
            UserData{ik} = ik;
        end
        ui_lb_data.String = items;
        ui_lb_data.UserData = UserData;        
    end

    function[im] = fn_rescale_img(im_i)
        im = abs(im_i).^0.0625;      
    end

    function fn_set_nr_grid_0(n_data, nx, ny)
        nr_grid.x = zeros(ny, nx, n_data, 'single');
        nr_grid.y = zeros(ny, nx, n_data, 'single');
    end
        
    function fn_plot_data(im_r, ik, p, sigma_gt, bd, title_r)
        [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(ik, :));
        pcf = ilc_pcf_2d(system_conf, im_r, double(data(:, :, ik)), 1, 1, A, txy, p, sigma_gt, bd);        

        axes(ax_f(2));
        imagesc(im_r);
        axis image off;
        colormap jet;
        title(title_r);
        zoom(fz_t(2));
        
        axes(ax_f(3));
        imagesc(pcf);
        axis image off;
        colormap jet;  
        title([title_r, ' - Image #= ', num2str(ik)]);
        zoom(fz_t(3));
        
        axes(ax_f(1));
    end

    function fn_show_rg_data(sigma_gt)
        [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(1, :));
        im_r = ilc_tr_at_2d(system_conf, double(data(:, :, 1)), 1, 1, A, txy);
        
        for ik=2:n_data
            title_r = ['Image # ', num2str(ik-1)];
            fn_plot_data(im_r, ik, p, sigma_gt, bd, title_r);
            
            [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(ik, :));
            im_r = ilc_tr_at_2d(system_conf, double(data(:, :, ik)), 1, 1, A, txy);
            
            ui_txt_msg.String =[ num2str(100*ik/n_data, '%4.1f'), ' %'];

            tm = str2double(ui_edt_time.String);
            tm = ilm_ifelse(isnan(tm), 0.075, tm);
            pause(tm);
        end 
    end

    function fn_show_nr_data(sigma_gt)
        if(~bb_nr)
            nr_grid = ilm_at_p_2_nr_grid(at_p, nx, ny);
        end
        
        [Rx_i, Ry_i] = meshgrid(0:(nx-1), 0:(ny-1));

        Rx_o = Rx_i + double(nr_grid.x(:, :, 1));
        Ry_o = Ry_i + double(nr_grid.y(:, :, 1));
        im_r = ilc_interp_rn_2d(system_conf, double(data(:, :, 1)), Rx_o, Ry_o);
        
        A = [1 0; 0 1];
        txy = [0; 0];
        for ik=2:n_data   
            title_r = ['Image # ', num2str(ik-1)];
            
            Rx_o = Rx_i + double(nr_grid.x(:, :, ik));
            Ry_o = Ry_i + double(nr_grid.y(:, :, ik));

            im_ik = ilc_interp_rn_2d(system_conf, double(data(:, :, ik)), Rx_o, Ry_o);
            pcf = ilc_pcf_2d(system_conf, im_r, im_ik, 1, 1, A, txy, p, sigma_gt);        
            
            axes(ax_f(2));
            imagesc(im_r);
            axis image off;
            colormap jet;
            title(title_r);
            zoom(fz_t(2));

            axes(ax_f(3));
            imagesc(pcf);
            axis image off;
            colormap jet;  
            title([title_r, ' - Image #= ', num2str(ik)]);
            zoom(fz_t(3));
            
            axes(ax_f(1));  
            
            im_r = im_ik;
            
            ui_txt_msg.String = [num2str(100*ik/n_data, '%4.1f'), ' %'];
            
            tm = str2double(ui_edt_time.String);
            tm = ilm_ifelse(isnan(tm), 0.075, tm);
            pause(tm);            
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cb_reset_txy(hobject, event)
        at_p(:, 5:6) = at_p0(:, 5:6);  
        
        % fill in ui_lb_data
        fn_set_lb_data_0(n_data);
            
        % select item in ui_lb_data
        cb_lb_data();

        % plot fimage
        fn_show_ax_f_1(true);         
    end

    function cb_reset_A(hobject, event)
        at_p(:, 1) = 1; 
        at_p(:, 2:3) = 0; 
        at_p(:, 4) = 1;
         
        % fill in ui_lb_data
        fn_set_lb_data_0(n_data);
            
        % select item in ui_lb_data
        cb_lb_data();

        % plot fimage
        fn_show_ax_f_1(true);         
    end

    function cb_assign_A_txy(hobject, event)
        fn_msn_start();
        
        nr_grid = ilm_at_p_2_nr_grid(at_p, nx, ny);
        
        fn_msn_end();
        
        bb_nr = true;
    end

    function cb_reset_data(hobject, event)
        data = data_i;
        n_data = ilm_nz_data(data);
        at_p = at_p0;
        bd = ilm_calc_borders_using_at_v(at_p);
        
        % reset nr_grid
        fn_set_nr_grid_0(n_data, nx, ny);
    
        % fill in ui_lb_data
        fn_set_lb_data_0(n_data);
            
        % select item in ui_lb_data
        cb_lb_data();

        % plot fimage
        fn_show_ax_f_1(true);      
    end

    function cb_press_key(obj, event)
        if(strcmpi(event.Key, 'delete'))
            
            b_ui_lb_data = ilm_gui_is_over_object(obj, ui_lb_data);
            if(~b_ui_lb_data)
                return
            end  

            fn_msn_start();
            
            ik_del = ui_lb_data.UserData{ui_lb_data.Value};
            data(:, :, ik_del) = [];
            n_data = ilm_nz_data(data);
            
            at_p(ik_del, :) = [];
            nr_grid.x(:, :, ik_del) = [];
            nr_grid.y(:, :, ik_del) = [];
            
            bd = ilm_calc_borders_using_at_v(at_p);           
            
            % fill in ui_lb_data
            fn_set_lb_data_0(n_data);
            ui_lb_data.Value = min(max(1, ik_del), n_data);
            
            % select item in ui_lb_data
            cb_lb_data();
            
            % plot fimage
            fn_show_ax_f_1(true);
            
            fn_msn_end();
        end
    end

    function cb_close(hobject, event)
        if(~bb_nr)
            nr_grid = ilm_at_p_2_nr_grid(at_p, nx, ny);
        end
        
        delete(fh);        
    end

    function cb_show_rg_av_image(hobject, event)
        fn_msn_start();
        
        image_av_rg = ilm_mean_data_at(system_conf, data, at_p);      

        figure(2);
        imagesc(image_av_rg);
        axis image off;
        colormap gray;
        title('Average image rg');
        
        fn_msn_end();
        
        figure(2);
    end

    function cb_show_nrg_av_image(hobject, event)    
        fn_msn_start();
        
        image_av_nrg = ilm_mean_data_nr_grid(system_conf, data, nr_grid);
        % set constant borders
        image_av_nrg = ilc_set_bd(image_av_nrg, 1, 1, bd, 3);
    
        figure(3);
        imagesc(image_av_nrg);
        axis image off;
        colormap gray;
        title('Average image nr');
        
        fn_msn_end();
        
        figure(3);
    end

    function cb_lb_data(hobject, event)
        sigma_gt = str2double(ui_edt_sigma.String);
        
        if(sigma_gt>sigma_g_max)
            return
        end
        
        fn_msn_start();
        
        ik_r = ui_lb_data.UserData{ui_lb_data.Value};
        ik_n = ilm_ifelse(ik_r==n_data, ik_r-1, ik_r+1);
        
        [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(ik_r, :));
        im_r = ilc_tr_at_2d(system_conf, double(data(:, :, ik_r)), 1, 1, A, txy);
        title_r = ['Image # ', num2str(ik_r)];

        fn_plot_data(im_r, ik_n, p, sigma_gt, bd, title_r);
        
        fn_msn_end();
    end 

    function cb_show_rg_data(hobject, event)
        sigma_gt = str2double(ui_edt_sigma.String);

        if(sigma_gt>sigma_g_max)
            return
        end

        fn_msn_start();
        
        fn_show_rg_data(sigma_gt);  
        
        cb_lb_data();
        
        fn_msn_end();
    end

    function cb_show_nr_data(hobject, event)
        sigma_gt = str2double(ui_edt_sigma.String);

        if(sigma_gt>sigma_g_max)
            return
        end

        fn_msn_start();
        
        fn_show_nr_data(sigma_gt);  
        
        cb_lb_data();
        
        fn_msn_end();
    end

    function cb_apply_txy(hobject, event)
        x_0t = str2double(ui_edt_x0.String);
        y_0t = str2double(ui_edt_y0.String);
        
        if((abs(x_0t)<1e-3)&&(abs(y_0t)<1e-3))
            ui_edt_x0.String = '0.00';
            ui_edt_y0.String = '0.00';
            return
        end

        fn_msn_start();
        
        at_p(:, 5:6) = at_p(:, 5:6) + [x_0t, y_0t];
        ui_edt_x0.String = '0.00';
        ui_edt_y0.String = '0.00';
        
        % fill in ui_lb_data
        fn_set_lb_data_0(n_data);
        
        % plot fimage
        fn_show_ax_f_1(); 
        
        cb_lb_data();

        fn_msn_end();
    end

    function cb_crt_txy(hobject, event)
        sigma_gt = str2double(ui_edt_sigma.String);
        
        if(sigma_gt>sigma_g_max)
            return
        end

        fn_msn_start();
        
        rg_n_it = str2num(ui_edt_rg_n_it.String); %#ok<ST2NM>
        b_fit = true;
        sigma_rt = ilm_sigma_g_2_sigma_r(nx, ny, sigma_gt);
        radius = sigma_rt;
        p = 0.05;
        
        % calculate shifting between images
        at_p = ilm_fd_tr_2d_bi(system_conf, data, p, sigma_gt, radius, bd, at_p, rg_n_it, b_fit);
        
		% center shifts
		at_p = ilm_center_tr_2d_using_at_v(at_p); 
	
        % calculate borders
        bd = ilm_calc_borders_using_at_v(at_p);
        
        % fill in ui_lb_data
        fn_set_lb_data_0(n_data);
        
        % plot fimage
        fn_show_ax_f_1();  
        
        % show pcf
%         fn_show_rg_data(sigma_gt);

        % select item in ui_lb_data
        cb_lb_data();   
        
        fn_msn_end();
    end

    function cb_crt_A_txy(hobject, event)
        sigma_gt = str2double(ui_edt_sigma.String);
        
        if(sigma_gt>sigma_g_max)
            return
        end

        fn_msn_start();
        
        rg_n_it = str2num(ui_edt_rg_n_it.String); %#ok<ST2NM>
        
        % find affine transformation
        at_p = ilm_run_rg_stem(system_conf, data, p, sigma_gt, at_p, rg_n_it);

        % calculate borders
        bd = ilm_calc_borders_using_at_v(at_p);
        
        % fill in ui_lb_data
        fn_set_lb_data_0(n_data);
        
        % plot fimage
        fn_show_ax_f_1();  
        
        % show pcf
%         fn_show_rg_data(sigma_gt);

        % select item in ui_lb_data
        cb_lb_data(); 
        
        fn_msn_end();
    end

    function cb_crt_nr_grid(hobject, event)
        fn_msn_start();
        
        sigma_gt = str2double(ui_edt_sigma.String);
        sigma_r = 1/(2*pi*sigma_gt*min(1/nx, 1/ny));
        alpha = str2double(ui_edt_alpha.String);
        
        nrg_n_it_i = str2num(ui_edt_nrg_n_it_i.String); %#ok<ST2NM>
        nrg_n_it_o = str2num(ui_edt_nrg_n_it_o.String); %#ok<ST2NM>
        
        opt = ui_pp_opt.Value;
        
        nr_grid = ilm_run_nr_stem(system_conf, data, bd, alpha, sigma_r, nr_grid, nrg_n_it_i, nrg_n_it_o, opt);       
        
        fn_msn_end();
    end

    function cb_mouse_move(hobject, event)
        axes(ax_f(1));
        b_ax_f_1 = ilm_gui_is_over_object(hobject, ax_f(1));
        if(~b_ax_f_1)
            return
        end
        
        C = get(ax_f(1), 'CurrentPoint');
        sigma_gt = sqrt((C(1,1)-x_c)^2+(C(1,2)-y_c)^2);
        sigma_rt = 1/(2*pi*sigma_gt*min(1/nx, 1/ny));
        
        children = get(ax_f(1), 'Children');
        delete(findobj(children, 'Type', 'Line'));
        
        axes(ax_f(1));
        title(ax_f(1), ['sigma_g = ', num2str(sigma_gt, '%6.2f'), ' px. , sigma_r = ', num2str(sigma_rt, '%6.2f'), ' px.']);

        % plot circle
        ilm_plot_circle(x_c, y_c, sigma_gt, 'green');
        
        % plot selected circle
        sigma_gt = str2double(ui_edt_sigma.String);
        ilm_plot_circle(x_c, y_c, sigma_gt, 'red');      
    end

    function cb_mouse_click(hobject, event)
        b_ax_f_1 = ilm_gui_is_over_object(hobject, ax_f(1));
        if(~b_ax_f_1)
            return
        end
        
        C = get(ax_f(1), 'CurrentPoint');
        sigma_gt = sqrt((C(1,1)-x_c)^2+(C(1,2)-y_c)^2);
        sigma_rt = 1/(2*pi*sigma_gt*min(1/nx, 1/ny));

        children = get(ax_f(1), 'Children');
        delete(findobj(children, 'Type', 'Line'));
        
        if(sigma_gt>sigma_g_max)
            return
        end
        
        axes(ax_f(1));
        title(ax_f(1), ['sigma_g = ', num2str(sigma_gt, '%6.2f'), ' px. , sigma_r = ', num2str(sigma_rt, '%6.2f'), ' px.']);

        % set sigma
        ui_edt_sigma.String = num2str(sigma_gt, '%5.2f');
        
        % plot circle
        ilm_plot_circle(x_c, y_c, sigma_gt, 'red');

        cb_lb_data();
    end

    function cb_zoom_fimage(hobject, event)       
        fz = 1;
        if(event.VerticalScrollCount<0)
            fz = 1.5;
        elseif(event.VerticalScrollCount>0)
            fz = 1/1.5;
        end
        
        if(ilm_gui_is_over_object(hobject, ax_f(1)))
            fz_t(1) = fz_t(1)*fz;            
            axes(ax_f(1));
            zoom(fz);
        elseif(ilm_gui_is_over_object(hobject, ax_f(2)))   
            fz_t(2) = fz_t(2)*fz; 
            axes(ax_f(2));
            zoom(fz);            
        elseif(ilm_gui_is_over_object(hobject, ax_f(3)))   
            fz_t(3) = fz_t(3)*fz; 
            axes(ax_f(3));
            zoom(fz);
        end
    end 
end