function[at_p, radius] = ilm_stem_4d_aligment(system_conf, data, at_p0)
    global n_data nx ny x_c y_c sigma_g_max
    global b_break fz_t bg_opt bg cbed_r cbed_m fcbed_m
    global n_idx idx
    
    close all
    
    bg_opt = 6;
    bg = 0;
    
    b_break = false;

    [ny, nx, n_data] = ilm_size_data(data);
    [Rx, Ry] = meshgrid(1:nx, 1:ny);
    
    n_idx = min(256, n_data);
    idx = randperm(n_data, n_idx);
    
    if(nargin<3)
        at_p0 = ilm_dflt_at_p(n_data);
    end
    
    at_p = at_p0;

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
    set(fh, {'Name', 'Visible', 'units', 'position', 'CloseRequestFcn'}, {'Tomo aligment', 'on', 'pixels',[x0, y0, x0+w, y0+h], @cb_close})
    movegui(fh, 'center');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ui_pn_opt = uipanel('Parent', fh, 'Title', 'Options', 'Units', 'normalized',...,
    'FontSize', 12, 'BackgroundColor', 'white', 'Position', [0.425 0.725 0.45 0.15]);

    pn_x_0 = 12;
    pn_y_1 = 65;
    pn_y_2 = 32;
    pn_w_0 = 90;
    pn_d = 4;    
    pn_h = 24;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pn_n = 8;    
    pn_w = pn_w_0*ones(1, pn_n);
    pn_x = pn_x_0*ones(1, pn_n);
    
    pn_w([3:pn_n]) = [35, 35, 35, 45, 60, 90];
    
    for ik=2:pn_n
        pn_x(ik) = pn_x(ik-1) + pn_d + pn_w(ik-1);
    end
    
    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Reset txy', 'Position', [pn_x(1) pn_y_1 pn_w(1) pn_h], 'Callback', @cb_reset_txy); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'Crt. txy', 'Position', [pn_x(2) pn_y_1 pn_w(2) pn_h], 'Callback', @cb_crt_txy); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'n_it', 'Position', [pn_x(3) pn_y_1 pn_w(3) pn_h]);

    ui_edt_rg_n_it = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '1', 'Position', [pn_x(4) pn_y_1 pn_w(4) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'p_br', 'Position', [pn_x(5) pn_y_1 pn_w(5) pn_h]);
    
    ui_edt_p_br = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.05', 'Position', [pn_x(6) pn_y_1 pn_w(6) pn_h]);

    ui_cb_fit = uicontrol('Parent', ui_pn_opt, 'Style', 'checkbox',... 
    'String', 'fitting', 'Value', 1, 'Position', [pn_x(7) pn_y_1 pn_w(7) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Show data', 'Position', [pn_x(8) pn_y_1 pn_w(8) pn_h], 'Callback', @cb_show_data); 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pn_n = 6;    
    pn_w = pn_w_0*ones(1, pn_n);
    pn_x = pn_x_0*ones(1, pn_n);
    pn_w(5) = 120;
    
    for ik=2:pn_n
        pn_x(ik) = pn_x(ik-1) + pn_d + pn_w(ik-1);
    end 

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',...
    'String', 'Sigma_g(px.)', 'Position', [pn_x(1) pn_y_2 pn_w(1) pn_h]);
    
    ui_edt_sigma = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',...
    'String', num2str(sigma_g_max/2, '%5.2f'), 'Position', [pn_x(2) pn_y_2 pn_w(2) pn_h]); 
    
    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'Time(s.)', 'Position', [pn_x(3) pn_y_2 pn_w(3) pn_h]);
    
    ui_edt_time = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.075', 'Position', [pn_x(4) pn_y_2 pn_w(4) pn_h]);

    ui_txt_msg = uicontrol('Parent', ui_pn_opt, 'Style', 'text',...
    'String', '00.0%', 'Position', [pn_x(5) pn_y_2 pn_w(5) pn_h], 'FontSize', 13, 'FontWeight', 'bold');  

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'Close', 'Position', [pn_x(6) pn_y_2 pn_w(6) pn_h], 'Callback', @cb_close);  

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    d_f = 0.010;    
    h_f = 0.45;    
    w_1 = 0.085;
    w_2 = h_f*h/w;
    w_3 = w_2;
    w_4 = w_3;
    w_5 = w_4;
    
    x_1 = (1-(w_1+w_2+w_3+w_4+w_5+4*d_f))/2;  
    x_2 = x_1+w_1+d_f;
    x_3 = x_2+w_2+d_f;
    x_4 = x_3+w_3+d_f;  
    x_5 = x_4+w_4+d_f;
    y_0 = 0.05;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ui_lb_data = uicontrol('Style', 'listbox', 'Units', 'normalized',...
        'Position', [x_1 y_0 w_1 h_f], 'Callback', @cb_lb_data);
    
    ax_f(1) = axes('Position', [x_2 y_0 w_2 h_f], 'Visible', 'off'); 
    ax_f(2) = axes('Position', [x_3 y_0 w_3 h_f], 'Visible', 'off'); 
    ax_f(3) = axes('Position', [x_4 y_0 w_4 h_f], 'Visible', 'off'); 
    ax_f(4) = axes('Position', [x_5 y_0 w_5 h_f], 'Visible', 'off'); 
    
    fh.WindowButtonMotionFcn = @cb_mouse_move;
    fh.WindowButtonDownFcn = @cb_mouse_click;
    fh.WindowScrollWheelFcn = @cb_zoom;

    % calculate
    [cbed_m, fcbed_m] = fn_cbed_fcbed_m();
    [cbed_r, ~, radius] = fn_cbed_r(cbed_m);
    
    sigma_gt = ilc_info_limit_2d(fcbed_m);
    ui_edt_sigma.String = num2str(sigma_gt, '%5.2f');
    
    % set initial zoom    
    fz_t(1) = sigma_g_max/(2*ilc_info_limit_2d(fcbed_m));
    fz_t(2) = 1;   
    fz_t(3) = 1;
    fz_t(4) = sigma_g_max/min(sigma_g_max/2, max(sigma_g_max/5, 6*ilm_sigma_g_2_sigma_r(nx, ny, sigma_gt)));
    
    % plot fcbed_m
    fn_show_ax_f_1();

    % set initial lb_data values
    fn_set_lb_at_p();
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

    function fn_set_lb_at_p()
        items{1, n_idx} = [];
        UserData{1, n_idx} = [];
        for ik=1:n_idx
            idx_ik = idx(ik);
            s_at_p_ik = ['[', num2str(at_p(idx_ik, 5), '%5.2f'), ', ', num2str(at_p(idx_ik, 6), '%5.2f'), ']'];

            items{ik} = [num2str(ik, '%.5d'), ' - ', s_at_p_ik]; 
            UserData{ik} = idx_ik;
        end
        ui_lb_data.String = items;
        ui_lb_data.UserData = UserData;        
    end

    function fn_show_ax_f_1()        
        % set axes
        axes(ax_f(1));
        imagesc(fn_rescale_fcbed(fcbed_m));      
        axis image off;
        colormap jet; 

        % plot circle
        sigma_gt = str2double(ui_edt_sigma.String);
        ilm_plot_circle(x_c, y_c, sigma_gt, 'red'); 
        
        zoom(fz_t(1));
    end

    function[im] = fn_rescale_fcbed(im_i, alpha)
        if(nargin<2)
            alpha = 0.125;
        end
        alpha = max(0.01, abs(alpha));
        im = abs(im_i).^alpha;      
    end

    function [cbed_m, fcbed_m] = fn_cbed_fcbed_m()
        fn_msn_start();
        
        [ny, nx, ~] = ilm_size_data(data);
        cbed_m = zeros(ny, nx);
        for ik = 1:n_idx
            idx_ik = idx(ik);
            cbed_m = cbed_m + ilc_tr_2d(system_conf, double(data(idx_ik).image), 1, 1, at_p(idx_ik, 5:6), bg_opt, bg);
        end
        cbed_m = cbed_m/n_idx;
        
        fcbed_m = fftshift(abs(fft2(cbed_m)));

        fn_msn_end();
    end

    function [cbed_r, txy, radius] = fn_cbed_r(cbed_m)
        cbed_r = imgaussfilt(cbed_m, 1.0);
        cbed_r = ilm_min_max_ni(cbed_r);
        level = ilc_otsu_thr(cbed_r, 256);
        cbed_bin = cbed_r>level;
        radius = sqrt(sum(cbed_bin(:))/pi);
        txy = [x_c, y_c] - [sum(Rx(cbed_bin)), sum(Ry(cbed_bin))]/sum(cbed_bin(:));
        txy = round(txy);
        
        cbed_r = ilc_tr_2d(system_conf, cbed_r, 1, 1, txy, bg_opt, bg);
        cbed_r = min(level, max(0, cbed_r));
        cbed_r = cbed_r*sum(cbed_m(:))/sum(cbed_r(:));
        
%         cbed_r = cbed_r>level;
%         radius = sqrt(sum(cbed_r(:))/pi);
%         cbed_r = ilc_func_butterworth(nx, ny, 1, 1, radius, 16, 0);
%         cbed_r = cbed_r*sum(cbed_m(:))/sum(cbed_r(:));
%         cbed_r = cbed_m;
    end

    function [bb] = fn_is_over_object(hobject, obj)
        % get the figure position, [x y width height]
        fh_pos = get(hobject, 'Position');

        % get the current position of the mouse
        fh_mpos = get(hobject, 'CurrentPoint');
        m_x = fh_mpos(1);
        m_y = fh_mpos(2);  
        
        ax_pos = get(obj, 'Position');
        
        ax_x0 = ax_pos(1)*fh_pos(3);
        ax_xe = (ax_pos(1)+ax_pos(3))*fh_pos(3);
        ax_y0 = ax_pos(2)*fh_pos(4);
        ax_ye = (ax_pos(2)+ax_pos(4))*fh_pos(4); 
        
        bb = (m_x>=ax_x0) && (m_x<=ax_xe) &&  (m_y>=ax_y0) && (m_y<=ax_ye);      
    end

    function fn_plot_data(cbed_r, ik, p, sigma_gt, bd)
        [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(ik, :));
        cbed_ik = double(data(ik).image);
        pcf = ilc_pcf_2d(system_conf, cbed_r, cbed_ik, 1, 1, A, txy, p, sigma_gt, bd, bg_opt, bg);       
        cbed_ik = ilc_tr_2d(system_conf, cbed_ik, 1, 1, txy, bg_opt, bg);
%         cbed_ik = ilc_tr_at_2d(system_conf, cbed_ik, 1, 1, A, txy, bg_opt, bg);
        
        axes(ax_f(2));
        imagesc(cbed_r);
        axis image off;
        colormap jet;
        title('Cbed_r');
        zoom(fz_t(2));
        
        axes(ax_f(3));
        imagesc(cbed_ik);
        axis image off;
        colormap jet;
        title(['Cbed_{', num2str(ik), '}']);
        zoom(fz_t(3));
        
        axes(ax_f(4));
        imagesc(pcf);
        axis image off;
        colormap jet;  
        title(['Cbed_r - Cbed_{', num2str(ik), '}']);
        zoom(fz_t(4));
        
        axes(ax_f(1));
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cb_reset_txy(hobject, event)
        at_p(:, 5:6) = at_p0(:, 5:6);  

        [cbed_m, fcbed_m] = fn_cbed_fcbed_m();
        cbed_r = fn_cbed_r(cbed_m);
    
        % fill in ui_lb_data
        fn_set_lb_at_p();
            
        % select item in ui_lb_data
        cb_lb_data();

        % plot fcbed_m
        fn_show_ax_f_1();         
    end

    function cb_close(hobject, event)
        delete(fh);        
    end

    function cb_lb_data(hobject, event)
        sigma_gt = str2double(ui_edt_sigma.String);       
        if(sigma_gt>sigma_g_max)
            return
        end
        
        fn_msn_start();
        
        p = str2double(ui_edt_p_br.String);
        bd = ilm_calc_borders_using_at_v(at_p); 
        
        ik = ui_lb_data.UserData{ui_lb_data.Value};        
        fn_plot_data(cbed_r, ik, p, sigma_gt, bd);
        
        fn_msn_end();
    end 

    function cb_show_data(hobject, event)
        sigma_gt = str2double(ui_edt_sigma.String);

        if(sigma_gt>sigma_g_max)
            return
        end

        fn_msn_start();
        
        p = str2double(ui_edt_p_br.String);
        bd = ilm_calc_borders_using_at_v(at_p); 
        for ik=1:n_idx 
            idx_ik = idx(ik);
            fn_plot_data(cbed_r, idx_ik, p, sigma_gt, bd);
            ui_txt_msg.String = [num2str(100*ik/n_idx, '%4.1f'), ' %'];

            tm = str2double(ui_edt_time.String);
            tm = ilm_ifelse(isnan(tm), 0.075, tm);
            pause(tm);
        end 

        cb_lb_data();
        
        fn_msn_end();
    end

    function cb_crt_txy(hobject, event)
        sigma_gt = str2double(ui_edt_sigma.String);
        
        if(sigma_gt>sigma_g_max)
            return
        end

        fn_msn_start();
        
%         rg_n_it = str2num(ui_edt_rg_n_it.String); %#ok<ST2NM>
%         p = str2double(ui_edt_p_br.String);
%         bd = ilm_calc_borders_using_at_v(at_p); 
%         b_fit = ui_cb_fit.Value;
%         
%         % calculate shifting between images
%         at_p = ilm_fd_tr_2d_ri(system_conf, cbed_r, data, p, sigma_gt, bd, at_p, rg_n_it, b_fit);
        
        idx = randperm(n_data, n_idx);
        [cbed_m, fcbed_m] = fn_cbed_fcbed_m();
        [cbed_r, txy, radius] = fn_cbed_r(cbed_m);
        at_p(:, 5:6) = at_p(:, 5:6) + txy;

        % fill in ui_lb_data
        fn_set_lb_at_p();
        
        % plot fcbed_m
        fn_show_ax_f_1();  
        
        % select item in ui_lb_data
        cb_lb_data();   
        
        fn_msn_end();
    end

    function cb_mouse_move(hobject, event)
        b_ax_f_1 = fn_is_over_object(hobject, ax_f(1));
        if(~b_ax_f_1)
            return
        end
        
        C = get(ax_f(1), 'CurrentPoint');
        sigma_gt = sqrt((C(1,1)-x_c)^2+(C(1,2)-y_c)^2);
        sigma_rt = ilm_sigma_g_2_sigma_r(nx, ny, sigma_gt);
        
        children = get(ax_f(1), 'Children');
        delete(findobj(children, 'Type', 'Line'));
        
        axes(ax_f(1));
        title(ax_f(1), ['sigma_g = ', num2str(sigma_gt, '%6.2f'), ' px. , sigma_r = ', num2str(sigma_rt, '%6.2f'), ' px.']);

        % plot selected circle
        sigma_set = str2double(ui_edt_sigma.String);
        ilm_plot_circle(x_c, y_c, sigma_set, 'red');
        
        % plot circle
        ilm_plot_circle(x_c, y_c, sigma_gt, 'green');       
    end

    function cb_mouse_click(hobject, event)
        b_ax_f_1 = fn_is_over_object(hobject, ax_f(1));
        if(~b_ax_f_1)
            return
        end
        
        C = get(ax_f(1), 'CurrentPoint');
        sigma_gt = sqrt((C(1,1)-x_c)^2+(C(1,2)-y_c)^2);
        sigma_rt = ilm_sigma_g_2_sigma_r(nx, ny, sigma_gt);

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

    function cb_zoom(hobject, event)       
        fz = 1;
        if(event.VerticalScrollCount<0)
            fz = 1.5;
        elseif(event.VerticalScrollCount>0)
            fz = 1/1.5;
        end
        
        if(fn_is_over_object(hobject, ax_f(1)))
            fz_t(1) = fz_t(1)*fz;            
            axes(ax_f(1));
            zoom(fz);
        elseif(fn_is_over_object(hobject, ax_f(2)))   
            fz_t(2) = fz_t(2)*fz; 
            axes(ax_f(2));
            zoom(fz); 
        elseif(fn_is_over_object(hobject, ax_f(3)))  
            fz_t(3) = fz_t(3)*fz; 
            axes(ax_f(3));
            zoom(fz);       
        elseif(fn_is_over_object(hobject, ax_f(4)))  
            fz_t(4) = fz_t(4)*fz; 
            axes(ax_f(4));
            zoom(fz);
        end
    end 
end