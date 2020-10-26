function[data, p_rect_sel] = ilm_gui_tomo_aligment(system_conf, data_i, angles_i, at_p0, bg_opt, bg)
    global n_data nx ny x_c y_c sigma_g_max fim ik_ref
    global fz_t dx dy pm_0 b_stop radius_f btw_np at_p 
    global f_xy fs_ax fs_ay fs_x_c fs_y_c
    global data_min data_max data_mean bb_shift_kpf bb_mouse_click
    
    bb_shift_kpf = false;
    bb_mouse_click = false;
    
    close all

    b_stop = false;
    if(nargin<3)
        angles_i = (0:1:(size(data_i, 3)-1))*2;
    end
    
    [~, ik_ref] = min(abs(angles_i));
    
    bg = 0;
    
    if(nargin<4)
        n_data = ilm_nz_data(data_i);
        at_p0 = ilm_dflt_at_p(n_data);
    end
        
    if(nargin<5)
        bg_opt = 1;
    end

    fy = 0.60;
    fx = 0.75;
    dm = get(0, 'MonitorPositions');
    dm = dm(1, :);
    w = fx*dm(3);
    h = fy*dm(4);
    x0 = (1-fx)*w/2;
    y0 = (1-fy)*h/2;

    fh = figure(1); clf;
    set(fh, {'Name', 'Visible', 'units', 'position', 'CloseRequestFcn'}, {'Tomo aligment -- Software created by Ivan Lobato: Ivanlh20@gmail.com ', 'on', 'pixels',[x0, y0, x0+w, y0+h], @cb_close})
    movegui(fh, 'center');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ui_pn_opt = uipanel('Parent', fh, 'Title', 'Options', 'Units', 'normalized',...,
    'FontSize', 12, 'BackgroundColor', 'white', 'Position', [0.05 0.75 0.90 0.23]);

    pn_x_0 = 12;
    pn_y_1 = 130;
    pn_y_2 = 90;
    pn_y_3 = 50;
    pn_y_4 = 10;
    pn_d = 4;    
    pn_h = 24;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pn_w = [55, 55, 55, 35, 35, 55, 60, 45, 340, 50, 50, 50];
    pn_n = length(pn_w);
    pn_x = pn_x_0*ones(1, pn_n);
    
    for ik=2:pn_n
        pn_x(ik) = pn_x(ik-1) + pn_d + pn_w(ik-1);
    end

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'Crt. tx', 'Position', [pn_x(1) pn_y_1 pn_w(1) pn_h], 'Callback', @(src, ev)cb_crt_txy(1)); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'Crt. ty', 'Position', [pn_x(2) pn_y_1 pn_w(2) pn_h], 'Callback', @(src, ev)cb_crt_txy(2)); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'Crt. txy', 'Position', [pn_x(3) pn_y_1 pn_w(3) pn_h], 'Callback', @(src, ev)cb_crt_txy(3)); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'n_it', 'Position', [pn_x(4) pn_y_1 pn_w(4) pn_h]);

    ui_edt_rg_n_it = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '1', 'Position', [pn_x(5) pn_y_1 pn_w(5) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'bg_opt', 'Position', [pn_x(6) pn_y_1 pn_w(6) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'popup',...
    'String', {'min', 'max', 'mean', 'min_mean', 'min_max', 'user', 'input'},...
    'Position', [pn_x(7) pn_y_1 pn_w(7) pn_h], 'Value', 1, 'Callback', @cb_set_bg_opt); 

    ui_edt_bg = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'Enable', 'off', 'String', '0', 'Position', [pn_x(8) pn_y_1 pn_w(8) pn_h], 'Callback', @cb_edt_bg);

    ui_bg_opt = uibuttongroup('Parent', ui_pn_opt, 'units', 'Pixels',...
        'Position', [pn_x(9) pn_y_1 pn_w(9) pn_h], 'SelectionChangedFcn', @cb_execute_selection);

    ui_rb_move = uicontrol('Parent', ui_bg_opt, 'Style', 'radiobutton',...
        'String', 'move', 'Position', [pn_x_0 0 50 pn_h]);

    ui_rb_select = uicontrol('Parent', ui_bg_opt, 'Style', 'radiobutton',...
        'String', 'select', 'Position', [pn_x_0+(48+pn_d) 0 50 pn_h]);

    ui_rb_add_bd = uicontrol('Parent', ui_bg_opt, 'Style', 'radiobutton',...
        'String', 'add bd', 'Position', [pn_x_0+(100+2*pn_d) 0 60 pn_h]);
    
    ui_rb_damp = uicontrol('Parent', ui_bg_opt, 'Style', 'radiobutton',...
        'String', 'damp', 'Position', [pn_x_0+(155+3*pn_d) 0 60 pn_h]);
    
    ui_rb_resize = uicontrol('Parent', ui_bg_opt, 'Style', 'radiobutton',...
        'String', 'resize', 'Position', [pn_x_0+(202+4*pn_d) 0 50 pn_h]);
    
    ui_rb_crop = uicontrol('Parent', ui_bg_opt, 'Style', 'radiobutton',...
        'String', 'crop', 'Position', [pn_x_0+(252+5*pn_d) 0 50 pn_h]);
    
    ui_edt_sampling_x = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0', 'Position', [pn_x(10) pn_y_1 pn_w(10) pn_h]);

    ui_edt_sampling_y = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0', 'Position', [pn_x(11) pn_y_1 pn_w(11) pn_h]);

    ui_pb_execute = uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Exec.', 'Position', [pn_x(12) pn_y_1 pn_w(12) pn_h], 'Callback', @cb_execute); 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pn_w = [45, 45, 45, 45, 70, 70, 70, 70, 70, 70, 70, 70, 70];
    pn_n = length(pn_w);
    pn_x = pn_x_0*ones(1, pn_n);
    
    for ik=2:pn_n
        pn_x(ik) = pn_x(ik-1) + pn_d + pn_w(ik-1);
    end  
    
    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'txy_s', 'Position', [pn_x(1) pn_y_2 pn_w(1) pn_h]);

    ui_edt_x0 = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.00', 'Position', [pn_x(2) pn_y_2 pn_w(2) pn_h], 'Callback', @cb_apply_tot_shift_x_or_y);

    ui_edt_y0 = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.00', 'Position', [pn_x(3) pn_y_2 pn_w(3) pn_h], 'Callback', @cb_apply_tot_shift_x_or_y);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'shift', 'Position', [pn_x(4) pn_y_2 pn_w(4) pn_h], 'Callback', @cb_apply_tot_shift); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'align cm', 'Position', [pn_x(5) pn_y_2 pn_w(5) pn_h], 'Callback', @cb_align_cm); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'crt. sc', 'Position', [pn_x(6) pn_y_2 pn_w(6) pn_h], 'Callback', @cb_crt_sc); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'crt. tx', 'Position', [pn_x(7) pn_y_2 pn_w(7) pn_h], 'Callback', @cb_crt_tx); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'crt. theta', 'Position', [pn_x(8) pn_y_2 pn_w(8) pn_h], 'Callback', @cb_crt_theta); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'apply txy', 'Position', [pn_x(9) pn_y_2 pn_w(9) pn_h], 'Callback', @cb_apply_txy); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Norm. data', 'Position', [pn_x(10) pn_y_2 pn_w(10) pn_h], 'Callback', @cb_norm_data); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Sub. min', 'Position', [pn_x(11) pn_y_2 pn_w(11) pn_h], 'Callback', @cb_sub_min); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'show Proj.', 'Position', [pn_x(12) pn_y_2 pn_w(12) pn_h], 'Callback', @cb_show_proj); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'mean Proj.', 'Position', [pn_x(13) pn_y_2 pn_w(13) pn_h], 'Callback', @cb_show_im_mean); 

    fn_activate_opt(0);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pn_w = [75, 75, 60, 50, 70, 63, 50, 60, 50, 235, 55, 55];
    pn_n = length(pn_w);
    pn_x = pn_x_0*ones(1, pn_n);
    for ik=2:pn_n
        pn_x(ik) = pn_x(ik-1) + pn_d + pn_w(ik-1);
    end 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'reset txy', 'Position', [pn_x(1) pn_y_3 pn_w(1) pn_h], 'Callback', @cb_reset_txy); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'reset data', 'Position', [pn_x(2) pn_y_3 pn_w(2) pn_h], 'Callback', @cb_reset_data);
    
    uicontrol('Parent', ui_pn_opt, 'Style', 'text',...
    'String', 'Sigma_g', 'Position', [pn_x(3) pn_y_3 pn_w(3) pn_h]);
    
    ui_edt_sigma = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',...
    'String', ' ', 'Position', [pn_x(4) pn_y_3 pn_w(4) pn_h], 'Callback', @cb_edt_sigma); 
    
    ui_cb_rcfft = uicontrol('Parent', ui_pn_opt, 'Style', 'checkbox',... 
    'String', 'Recal. fft', 'Value', 1, 'Position', [pn_x(5) pn_y_3 pn_w(5) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',...
    'String', 'Exp. FFT', 'Position', [pn_x(6) pn_y_3 pn_w(6) pn_h]);
    
    ui_pu_exp = uicontrol('Parent', ui_pn_opt, 'Style', 'popup',...
    'String', {'0.100', '0.125', '0.20', '0.25', '0.5', '0.75'}, 'Value', 3,...
    'Position', [pn_x(7) pn_y_3 pn_w(7) pn_h], 'Callback', @(src, ev)fn_show_ax_f_1(false)); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'Time(s.)', 'Position', [pn_x(8) pn_y_3 pn_w(8) pn_h]);

    ui_edt_time = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.075', 'Position', [pn_x(9) pn_y_3 pn_w(9) pn_h]);

    ui_txt_msg = uicontrol('Parent', ui_pn_opt, 'Style', 'text',...
    'String', '00.0%', 'Position', [pn_x(10) pn_y_3 pn_w(10) pn_h], 'FontSize', 13, 'FontWeight', 'bold');  

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'stop', 'Position', [pn_x(11) pn_y_3 pn_w(12) pn_h], 'Callback', @cb_stop); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'Close', 'Position', [pn_x(12) pn_y_3 pn_w(12) pn_h], 'Callback', @cb_close);  

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pn_w = [850];
    pn_n = length(pn_w);
    pn_x = pn_x_0*ones(1, pn_n);
    
    for ik=2:pn_n
        pn_x(ik) = pn_x(ik-1) + pn_d + pn_w(ik-1);
    end 
    
    ui_pb_data_info = uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'Enable', 'inactive', 'String', ' ', 'Position', [pn_x(1) pn_y_4 pn_w(1) pn_h]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    d_f = 0.010;    
    h_f = 0.60;    
    w_1 = 0.10;
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
    
    axes_f(1) = axes('Position', [x_2 y_0 w_2 h_f], 'Visible', 'off'); 
    axes_f(2) = axes('Position', [x_3 y_0 w_3 h_f], 'Visible', 'off'); 
    axes_f(3) = axes('Position', [x_4 y_0 w_4 h_f], 'Visible', 'off'); 
    
    fn_init(system_conf, data_i, at_p0);
    
    fh.WindowButtonMotionFcn = @cb_mouse_move;
    fh.WindowButtonDownFcn = @cb_mouse_click;
    fh.WindowButtonUpFcn = @cb_mouse_release;
    fh.WindowScrollWheelFcn = @cb_zoom;
    fh.WindowKeyPressFcn = @cb_press_key;
    fh.WindowKeyReleaseFcn = @cb_release_key;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    uiwait(fh)
    
    function [typ]=fn_get_activate_typ()
        typ = ilm_ifelse(ui_rb_add_bd.Value, 1, 0);
        typ = ilm_ifelse(ui_rb_damp.Value, 2, typ);
        typ = ilm_ifelse(ui_rb_resize.Value, 3, typ);
        typ = ilm_ifelse(ui_rb_crop.Value, 4, typ);
   end
        
    function fn_activate_opt(typ)
        if(typ==0) % move or select
            ui_edt_sampling_x.Enable = 'off';
            ui_edt_sampling_y.Enable = 'off';
            
            ui_pb_execute.Enable = 'off';
        elseif(typ==1) % add bd
            ui_edt_sampling_x.String = num2str(0);
            ui_edt_sampling_x.Enable = 'on';
            
            ui_edt_sampling_y.String = num2str(0);
            ui_edt_sampling_y.Enable = 'on';
            
            ui_pb_execute.Enable = 'on';
        elseif(typ==2) % damp
            ui_edt_sampling_x.Enable = 'on';
            ui_edt_sampling_y.Enable = 'on';
            
            ui_edt_sampling_x.String = num2str(btw_np(1));
            ui_edt_sampling_y.String = num2str(btw_np(2));
            
            ui_pb_execute.Enable = 'on'; 
        elseif(typ==3) % resize 
            if(str2double(ui_edt_sampling_x.String)<64)
                ui_edt_sampling_x.String = num2str(nx);
            end
            ui_edt_sampling_x.Enable = 'on';
            
            if(str2double(ui_edt_sampling_y.String)<64)
                ui_edt_sampling_y.String = num2str(ny);
            end
            ui_edt_sampling_y.Enable = 'off';
            
            ui_pb_execute.Enable = 'on';
        elseif(typ==4) % crop
            ui_edt_sampling_x.Enable = 'off';
            ui_edt_sampling_y.Enable = 'off';
            
            ui_pb_execute.Enable = 'on';  
        end
    end

    function s = fn_str_data_info(p_rect_sel)
        s = ['[nx, ny] = [', num2str(nx), ', ', num2str(ny), ']'];
        s = [s, ' - [min, max, mean] = [', num2str(data_min, '%.3e'), ', ', num2str(data_max, '%.3e'), ', ', num2str(data_mean, '%.3e'), ']'];
        s = [s, ' - [ix_0, ix_e] = [', num2str(p_rect_sel(1,1)), ', ', num2str(p_rect_sel(2,1)), ']'];
        s = [s, ' - [iy_0, iy_e] = [', num2str(p_rect_sel(1,2)), ', ', num2str(p_rect_sel(2,2)), ']'];
        s = [s, ' - [nx_s, ny_s] = [', num2str(abs(p_rect_sel(2,1)-p_rect_sel(1,1))+1), ', ', num2str(abs(p_rect_sel(2, 2)-p_rect_sel(1,2))+1), ']'];
    end

    function fn_init(system_conf, data_i, at_p0, p_rect_sel_0)  
        fn_msn_start();
        
        bb_mouse_click = false;
        
        data = data_i;
        [ny, nx, n_data] = ilm_size_data(data);
        
        if(nx>ny)
            f_xy = [1, nx/ny];
        else
            f_xy = [ny/nx, 1];
        end
        
        fs_ax = (1:nx)*f_xy(1);
        fs_ay = (1:ny)*f_xy(2);
        fs_x_c = nx*f_xy(1)/2 + 1;
        fs_y_c = ny*f_xy(2)/2 + 1;
        
        dx = 1;
        dy = 1;
        
        x_c = nx/2 + 1;
        y_c = ny/2 + 1;
        
        if(nargin<4)
            p_rect_sel_0 = [1, 1; nx, ny];
        end
        
        p_rect_sel = p_rect_sel_0;
        btw_np = [32, 32];
        data_mean = mean(data(:));
        data_min = min(data(:));
        data_max = max(data(:));
        
        at_p = at_p0;
        pm_0 = [0, 0];

        % set sigma max
        sigma_g_max = min(nx/2, ny/2)-1;

        % set initial sigma
        fim = fn_mean_abs_fdata_at(system_conf, data, at_p);
        sigma_gt = ilc_info_limit_2d(fim);
        radius_f = 2.25;
        
        ui_edt_sampling_x.String = num2str(nx);
        ui_edt_sampling_y.String = num2str(ny);
        ui_edt_sigma.String = num2str(sigma_gt, '%5.2f');
        ui_pb_data_info.String = fn_str_data_info(p_rect_sel);
        
        % set initial zoom    
        fz_t(1) = sigma_g_max/(2*sigma_gt);
        fz_t(2) = 1;
        fz_t(3) = sigma_g_max/min(sigma_g_max/2, max(sigma_g_max/5, 6*ilm_sigma_g_2_sigma_r(nx, ny, sigma_gt)));

        % plot fim
        fn_show_ax_f_1(false);

        % set initial lb_data values
        fn_set_lb_at_p(at_p);
        ui_lb_data.Value = ik_ref;
        
        cb_lb_data();
        
        fn_msn_end();
    end
    
    function [image_av] = fn_mean_abs_fdata_at(system_conf, data, at_p)
        [ny, nx, n_data] = ilm_size_data(data);
        
        n_idx = max(2, round(n_data/2));
        a_idx = randperm(n_data, n_idx);
        
        image_av = zeros(ny, nx);
        radius = 0.85*min(nx, ny)/2;
        fbw = ilc_func_butterworth(nx, 1, 1, 1, radius, 8);
        fbw = fbw.*ilc_func_butterworth(1, ny, 1, 1, radius, 8);
        
        for ik = a_idx
            [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(ik, :));
            image_ik = double(data(:, :, ik));
            [image_ik, bg_ik] = ilc_tr_at_2d(system_conf, image_ik, 1, 1, A, txy, bg_opt, bg);
            image_ik = (image_ik-0.999*bg_ik).*fbw;
%             ilm_imagesc(1, image_ik); 
            image_av = image_av + abs(fft2(image_ik));
        end

        image_av = ifftshift(image_av/n_idx);
    end

    function fn_plot_rect_ax_f_2(p_rect_sel, tag)
        children = get(axes_f(2), 'Children');
        
        if(strcmpi(tag, 'f'))
            delete(findobj(children, 'Type', 'Line'));
            color = 'red';
            ui_pb_data_info.String = fn_str_data_info(p_rect_sel);
        else
            delete(findobj(children, 'Type', 'Line', '-and', 'Tag', 'm'));
            color = 'green';
        end

        % plot selected rectangle
        axes(axes_f(2));
        
        ilm_plot_rectangle(p_rect_sel, color, tag);
    end

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
            fim = fn_mean_abs_fdata_at(system_conf, data, at_p);
        end
        
        % set axes
        axes(axes_f(1));
        imagesc(fs_ax, fs_ay, fn_rescale_img(fim));  
        axis image off;
        colormap jet; 

        % plot circle
        sigma_gt = str2double(ui_edt_sigma.String);
        ilm_plot_circle(fs_x_c, fs_y_c, sigma_gt, 'red', 'f'); 
        
        zoom(fz_t(1));
    end

    function fn_set_lb_at_p(at_p)
        lb_val = ui_lb_data.Value;

        n_at_p = size(at_p, 1);
        items{1, n_at_p} = [];
        UserData{1, n_at_p} = [];
        
        for ik=1:n_at_p
            s_at_p_ik = [num2str(at_p(ik, 5), '%5.2f'), ', ', num2str(at_p(ik, 6), '%5.2f')];

            items{ik} = [num2str(ik, '%.3d'), ': ', num2str(angles_i(ik), '%3.1f') , '° | ', s_at_p_ik]; 
            UserData{ik} = ik;
        end
        ui_lb_data.String = items;
        ui_lb_data.UserData = UserData;   
        
        ui_lb_data.Value = lb_val;
    end

    function[im] = fn_rescale_img(im_i)
        alpha = str2double(ui_pu_exp.String{ui_pu_exp.Value});
        if(~isnumeric(alpha))
            alpha = 0.20;
        end
        
        alpha = max(0.01, abs(alpha));
        
        im = abs(im_i).^alpha;      
    end

    function fn_plot_data(im_r, ik, p, sigma_gt, bd, title_r)
        [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(ik, :));
        pcf = ilc_pcf_2d(system_conf, im_r, double(data(:, :, ik)), dx, dy, A, txy, p, sigma_gt, bd, bg_opt, bg);       

        axes(axes_f(2));
        imagesc(im_r);
        axis image off;
        colormap jet;
        title(title_r);
        
        % plot selected rectangle
        fn_plot_rect_ax_f_2(p_rect_sel, 'f');
        
        zoom(fz_t(2));
        
        axes(axes_f(3));
        imagesc(pcf);
        axis image off;
        colormap jet;  
        title(['Pcf #= ', num2str(ilm_set_bound(ik-1, 1, n_data+1)), ' - ', num2str(ik)]);
        
        % plot circle
        sigma_rt = ilm_sigma_g_2_sigma_r(nx, ny, sigma_gt);
        radius = radius_f*sigma_rt;
        
        ilm_plot_circle(x_c, y_c, sigma_rt, 'blue', 'f'); 
        ilm_plot_circle(x_c, y_c, radius, 'red', 'f'); 
        
        zoom(fz_t(3));
        
%         axes(axes_f(1));
    end

    function fn_show_rg_data(sigma_gt)
        [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(1, :));
        im_r = ilc_tr_at_2d(system_conf, double(data(:, :, 1)), dx, dy, A, txy, bg_opt, bg);
        
        p = 0.05;
        bd = fn_get_bd(at_p, p_rect_sel);
        for ik=2:n_data
            if(b_stop)
                break;
            end
            
            title_r = ['Image # ', num2str(ik-1), ' - theta = ', num2str(angles_i(ik-1)), '°'];
            fn_plot_data(im_r, ik, p, sigma_gt, bd, title_r);
            
            [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(ik, :));
            im_r = ilc_tr_at_2d(system_conf, double(data(:, :, ik)), dx, dy, A, txy, bg_opt, bg);
            
            ui_txt_msg.String = [num2str(100*ik/n_data, '%4.1f'), ' %'];

            tm = str2double(ui_edt_time.String);
            tm = ilm_ifelse(isnan(tm), 0.075, tm);
            pause(tm);
        end 
        b_stop = false;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cb_reset_data(source, event)
        fn_init(system_conf, data_i, at_p0)
    end

    function cb_edt_sigma(source, event)
        fn_show_ax_f_1(false);
        
        cb_lb_data();
    end

    function cb_reset_txy(source, event)
        at_p(:, 5:6) = at_p0(:, 5:6);  

        % fill in ui_lb_data
        fn_set_lb_at_p(at_p);
            
        % select item in ui_lb_data
        cb_lb_data();

        % plot fim
        fn_show_ax_f_1(ui_cb_rcfft.Value);         
    end

    function cb_show_im_mean(source, event)
        fn_msn_start();
        
        image_av_rg = ilm_mean_data_at(system_conf, data, at_p);      

        figure(2);
        imagesc(image_av_rg);
        axis image off;
        colormap jet;
        title('Average image rg');
        
        fn_msn_end();
        
        figure(2);
    end

    function cb_lb_data(source, event)
        sigma_gt = str2double(ui_edt_sigma.String);
        p = 0.05;
        bd = fn_get_bd(at_p, p_rect_sel);   
        
        if(sigma_gt>sigma_g_max)
            return
        end
        
        fn_msn_start();
        
        ik_r = ui_lb_data.UserData{ui_lb_data.Value};
        ik_n = ilm_ifelse(ik_r==n_data, ik_r-1, ik_r+1);
        
        [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(ik_r, :));
        im_r = ilc_tr_at_2d(system_conf, double(data(:, :, ik_r)), 1, 1, A, txy, bg_opt, bg);
        title_r = ['Image # ', num2str(ik_r), ' - theta = ', num2str(angles_i(ik_r)), '°'];
        
        fn_plot_data(im_r, ik_n, p, sigma_gt, bd, title_r);
        
        fn_msn_end();
    end 

    function cb_align_cm(source, event)
        fn_msn_start();
        
        ax = p_rect_sel(1,1):p_rect_sel(2,1);
        ay = p_rect_sel(1,2):p_rect_sel(2,2);
        
        [Rx, ~] = meshgrid(1:nx, 1:ny);
        Rx = Rx(ay, ax);
        x_c_t = 0;
        for ik=1:n_data
            [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(ik, :));
            im_ik = double(data(:, :, ik));
            im_ik = ilc_tr_at_2d(system_conf, im_ik, dx, dy, A, txy, bg_opt, bg); 
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            im_ik = reshape(im_ik(ay, ax), [], 1);
            x_c_ik = sum(Rx(:).*im_ik)/sum(im_ik) - x_c;
            x_c_t = x_c_t + x_c_ik;
            
            ui_txt_msg.String = [num2str(100*ik/n_data, '%4.1f'), ' %'];
            pause(0.001);
        end 
        x_c_t = x_c_t/n_data;
        
        at_p(:, 5:6) = at_p(:, 5:6) - [x_c_t, 0];
            
        % fill in ui_lb_data
        fn_set_lb_at_p(at_p);
        
        % plot fim
        fn_show_ax_f_1(false); 
        
        cb_lb_data();

        fn_msn_end();
    end

    function cb_crt_sc(source, event)
        fn_msn_start();
        
        st_tomo_data = fn_set_input_data_alignment(system_conf, data, angles_i, at_p, p_rect_sel, btw_np);
        sc = fn_fd_sc_using_sirt(st_tomo_data);
        
        data = data.*reshape(sc, 1, 1, n_data);
 
        fn_show_ax_f_1(false); 

        cb_lb_data();
        
        ui_pb_data_info.String = fn_str_data_info(p_rect_sel);
        
        fn_msn_end();
    end

    function cb_crt_tx(source, event)
        fn_msn_start();
        
        st_tomo_data = fn_set_input_data_alignment(system_conf, data, angles_i, at_p, p_rect_sel, btw_np);
        tx = fn_fd_tx_using_sirt(st_tomo_data);
        at_p(:, 5) = at_p(:, 5) + tx;
        
        % fill in ui_lb_data
        fn_set_lb_at_p(at_p);

        fn_show_ax_f_1(false); 
        
        cb_lb_data();

        fn_msn_end();
    end

    function cb_crt_theta(source, event)
        fn_msn_start();
        
        st_tomo_data = fn_set_input_data_alignment(system_conf, data, angles_i, at_p, p_rect_sel, btw_np);
        theta = ilm_fd_theta_using_sirt_3df(st_tomo_data);
        
        p_rc = [nx, ny]/2 - 0.5;
        for ik=1:n_data
            data_ik = double(data(:, :, ik));
            data_ik = ilc_rot_tr_2d(system_conf, data_ik, 1, 1, theta, p_rc, [0, 0], 1, 0); 
            data(:, :, ik) = max(0, data_ik);
        end
        Rm = ilm_rot_mat_2d(theta).';
        at_p(:, 5:6) = at_p(:, 5:6)*Rm;
        
        % fill in ui_lb_data
        fn_set_lb_at_p(at_p);

        fn_show_ax_f_1(false); 
        
        cb_lb_data();

        fn_msn_end();
    end

    function cb_show_proj(source, event)
        sigma_gt = str2double(ui_edt_sigma.String);

        if(sigma_gt>sigma_g_max)
            return
        end

        fn_msn_start();
        
        fn_show_rg_data(sigma_gt);  
        
        cb_lb_data();
        
        fn_msn_end();
    end
% 
    function cb_stop(source, event)
        b_stop = true;
    end

    function cb_apply_tot_shift(source, event)
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
        fn_set_lb_at_p(at_p);
        
        % plot fim
        fn_show_ax_f_1(ui_cb_rcfft.Value); 
        
        cb_lb_data();

        fn_msn_end();
    end

    function []= cb_apply_tot_shift_x_or_y(source, event)
        if(isequal(source, ui_edt_x0))
            x_0t = str2double(source.String);
            y_0t = 0;
            if(abs(x_0t)<1e-3)
                source.String = '0.00';
                return
            end
        else
            x_0t = 0;
            y_0t = str2double(source.String);
            if(abs(y_0t)<1e-3)
                source.String = '0.00';
                return
            end
        end

        fn_msn_start();
        
        at_p(:, 5:6) = at_p(:, 5:6) + [x_0t, y_0t];
        source.String = '0.00';
        
        % fill in ui_lb_data
        fn_set_lb_at_p(at_p);
        
        % plot fim
        fn_show_ax_f_1(ui_cb_rcfft.Value); 
        
        cb_lb_data();

        fn_msn_end();
    end

    function cb_apply_txy(source, event)
        fn_msn_start();
        
        for ik=1:n_data
            [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(ik, :));
            im_ik = double(data(:, :, ik));
            im_ik = ilc_tr_at_2d(system_conf, im_ik, dx, dy, A, txy, bg_opt, bg);
            if(data_min>=0)
                data(:, :, ik) = max(0, im_ik);
            else
                data(:, :, ik) = im_ik;
            end
            
            ui_txt_msg.String = [num2str(100*ik/n_data, '%4.1f'), ' %'];
            pause(0.01);
        end

        at_p = ilm_dflt_at_p(n_data);
        
        % set initial lb_data values
        fn_set_lb_at_p(at_p);
        
        cb_lb_data();
        
        fn_msn_end();
    end

    function cb_execute_selection(source, event)
        typ = fn_get_activate_typ();
        fn_activate_opt(typ)
    end

    function cb_set_bg_opt(source, event)
        bg_opt = ilm_set_bound(source.Value, 1, 7);
        bg = 0;
        if(bg_opt==6)
            ui_edt_bg.Enable = 'on';
            bg = str2double(ui_edt_bg.String);
        else
            ui_edt_bg.Enable = 'off';
        end
        
        cb_lb_data();
    end

    function cb_edt_bg(source, event)
        bg = str2double(ui_edt_bg.String);
        cb_lb_data();
    end

    function cb_norm_data(source, event)
        fn_msn_start();
        
        data = fn_norm_data(data);

        data_mean = mean(data(:));
        data_min = min(data(:));
        data_max = max(data(:));
        
        ui_pb_data_info.String = fn_str_data_info(p_rect_sel);
        
        fn_msn_end();
    end

    function cb_sub_min(source, event)
        fn_msn_start();
        
        data = data -  reshape(min(reshape(data, [], n_data)), 1, 1, n_data);

        data_mean = mean(data(:));
        data_min = min(data(:));
        data_max = max(data(:));
        
        ui_pb_data_info.String = fn_str_data_info(p_rect_sel);
        
        fn_msn_end();
    end

    function cb_execute(source, event)
        fn_msn_start();
        
        typ = fn_get_activate_typ();
        
        if(typ==1) % add bd
            bd_x = round(str2double(ui_edt_sampling_x.String));
            bd_x = ilm_pn_border(nx, bd_x, 1);
            nx_r = nx+2*bd_x;
            ix_0 = bd_x + 1;
            ix_e = ix_0 + nx-1;
            ax = ix_0:ix_e;
            
            bd_y = round(str2double(ui_edt_sampling_y.String));
            bd_y = ilm_pn_border(ny, bd_y, 1);
            ny_r = ny+2*bd_y;
            iy_0 = bd_y + 1;
            iy_e = iy_0 + ny-1;
            ay = iy_0:iy_e;
            
            data_t = zeros(ny_r, nx_r, n_data);
%             data_t(ay, ax, :) = data;
            for ik=1:n_data
                im_ik = double(data(:, :, ik));
                data_t(:, :, ik) = min(im_ik(:));
                data_t(ay, ax, ik) = im_ik;

                ui_txt_msg.String = [num2str(100*ik/n_data, '%4.1f'), ' %'];
                pause(0.001);
            end
            
            p_rect_sel_0 = p_rect_sel + [bd_x, bd_y];
            
            fn_init(system_conf, data_t, at_p, p_rect_sel_0);
            
            ui_edt_sampling_x.String = num2str(0);
            ui_edt_sampling_y.String = num2str(0);
            
        elseif(typ==2) % damp
            np_x = round(str2double(ui_edt_sampling_x.String));
            np_y = round(str2double(ui_edt_sampling_y.String));
            btw_np = [np_x, np_y];
            
            fw = ilm_func_butterworth_rect(nx, ny, p_rect_sel, np_x, np_y);

            for ik=1:n_data
                [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(ik, :));
                im_ik = double(data(:, :, ik));
                bg_sft = ilm_get_bg(im_ik, bg_opt, bg);
                im_ik = ilc_tr_at_2d(system_conf, im_ik, dx, dy, A, txy, 6, bg_sft);
                im_ik = max(0, (im_ik-bg_sft).*fw + bg_sft);
                
                data(:, :, ik) = im_ik;
                ui_txt_msg.String = [num2str(100*ik/n_data, '%4.1f'), ' %'];
                pause(0.001);
            end
            
            at_p = ilm_dflt_at_p(n_data);
            
            ui_pb_data_info.String = fn_str_data_info(p_rect_sel);
            
            % set initial lb_data values
            fn_set_lb_at_p(at_p);
            
            cb_lb_data();
            
        elseif(typ==3) % resize 
            nx_r = round(str2double(ui_edt_sampling_x.String));
            
            if(nx_r==0)
                return;
            end
            ny_r = round(nx_r*ny/nx);
            nx_r = ilc_pn_fact(nx_r);

            data_t = zeros(ny_r, nx_r, n_data);
            for ik=1:n_data
                im_ik = double(data(:, :, ik));
                data_t(:, :, ik) = max(0, imresize(im_ik, [ny_r, nx_r], 'bicubic'));

                ui_txt_msg.String = [num2str(100*ik/n_data, '%4.1f'), ' %'];
                pause(0.001);
            end

            at_p(:, 5:6) = at_p(:, 5:6).*[nx_r/nx, ny_r/ny]; 
            if(mod(ny_r, 2)==1)
                data_t = data_t(1:(end-1), :, :);
            end
            
            fn_init(system_conf, data_t, at_p);
            
            ui_edt_sampling_x.String = num2str(0);
            ui_edt_sampling_y.String = num2str(0);
        elseif(typ==4) % crop
            ax = p_rect_sel(1,1):p_rect_sel(2,1);
            ay = p_rect_sel(1,2):p_rect_sel(2,2);

            for ik=1:n_data
                [A, txy] = ilm_cvt_at_v_2_A_txy(at_p(ik, :));
                im_ik = double(data(:, :, ik));
                data(:, :, ik) = ilc_tr_at_2d(system_conf, im_ik, dx, dy, A, txy, bg_opt, bg);
                ui_txt_msg.String = [num2str(100*ik/n_data, '%4.1f'), ' %'];
                pause(0.001);
            end
            
            at_p = ilm_dflt_at_p(n_data);
            
            fn_init(system_conf, data(ay, ax, :), at_p);
        end
        
        fn_msn_end();
    end

    function[bd]=fn_get_bd(at_p, p_rect_sel)
        bd = ilm_calc_borders_using_at_v(at_p);
        bd_user = [p_rect_sel(1,1)-1, nx-p_rect_sel(2,1),  p_rect_sel(1,2)-1, ny-p_rect_sel(2,2)];
        bd =  max(bd, bd_user);
    end

    function cb_crt_txy(opt)
        sigma_gt = str2double(ui_edt_sigma.String);

        if(sigma_gt>sigma_g_max)
            return
        end

        fn_msn_start();

        rg_n_it = str2num(ui_edt_rg_n_it.String); %#ok<ST2NM>
        p = 0.05;
        
        bd = fn_get_bd(at_p, p_rect_sel);
        
        b_fit = true;
        sigma_rt = ilm_sigma_g_2_sigma_r(nx, ny, sigma_gt);
        radius = radius_f*sigma_rt;
        
        % calculate shifting between images
        at_p_r = ilm_fd_tr_2d_bi(system_conf, data, p, sigma_gt, radius, bd, at_p, rg_n_it, b_fit);
        
        if(opt==1)
            at_p(:, 5) = at_p_r(:, 5) - at_p_r(ik_ref, 5) + at_p(ik_ref, 5);
        elseif(opt==2)
            at_p(:, 6) = at_p_r(:, 6) - at_p_r(ik_ref, 6) + at_p(ik_ref, 6);
        else
            at_p(:, 5:6) = at_p_r(:, 5:6) - at_p_r(ik_ref, 5:6) + at_p(ik_ref, 5:6);
        end
        
        % fill in ui_lb_data
        fn_set_lb_at_p(at_p);
        
        % plot fim
        fn_show_ax_f_1(ui_cb_rcfft.Value);  
        
        % select item in ui_lb_data
        cb_lb_data();   
        
        fn_msn_end();
    end

    function cb_mouse_move(source, event)
%         axes(axes_f(1));
        if(~isnumeric(x_c))
            return
        end
        
        b_ax_f = ilm_gui_is_over_object(source, axes_f);
        
        if(b_ax_f(1))
            if(bb_shift_kpf)
                C = get(axes_f(1), 'CurrentPoint');
                sigma_gt = sqrt((C(1,1)-fs_x_c)^2+(C(1,2)-fs_y_c)^2);
                sigma_rt = ilm_sigma_g_2_sigma_r(nx, ny, sigma_gt);

                children = get(axes_f(1), 'Children');
                delete(findobj(children, 'Type', 'Line', '-and', 'Tag', 'm'));

                axes(axes_f(1));
                title(axes_f(1), ['sigma_g = ', num2str(sigma_gt, '%6.2f'), ' px. , sigma_r = ', num2str(sigma_rt, '%6.2f'), ' px.']);

                % plot circle
                ilm_plot_circle(fs_x_c, fs_y_c, sigma_gt, 'green', 'm');
            end
        elseif(b_ax_f(2))
            if(bb_mouse_click && ui_rb_select.Value)
                C = get(axes_f(2), 'CurrentPoint');
                C = [max(1, min(nx, round(C(1, 1)))), max(1, min(ny, round(C(1, 2))))];

                d = abs(p_rect_sel-C);
                [~, ii] = min(d(:));

                if(bb_shift_kpf)
                    if(ii<=2)
                        bx = ilm_ifelse(ii==1, C(1), nx-C(1));
                        bx = round((nx-ilc_pn_fact(nx-2*bx, 4))/2);
                        ix_0 = bx+1;
                        ix_e = nx-bx;
                        p_rect_sel(:,1) = [ix_0; ix_e];
                    else
                        by = ilm_ifelse(ii==3, C(2), ny-C(2));
                        by = round((ny-ilc_pn_fact(ny-2*by, 4))/2);
                        iy_0 = by+1;
                        iy_e = ny-by;
                        p_rect_sel(:,2) = [iy_0; iy_e];
                    end
                else
                    if(ii==1)
                        ix_e = p_rect_sel(2,1);
                        ix_0 = round(ix_e - ilc_pn_fact(round(ix_e-C(1)+1))+1);
                        p_rect_sel(1,1) = ilm_set_bound(ix_0, 1, nx);
                    elseif(ii==2)
                        ix_0 = p_rect_sel(1,1);
                        ix_e = round(ilc_pn_fact(round(C(1)-ix_0+1))+ ix_0-1);
                        p_rect_sel(2,1) = ilm_set_bound(ix_e, 1, nx);
                    elseif(ii==3)
                        iy_e = p_rect_sel(2, 2);
                        iy_0 = round(iy_e - ilc_pn_fact(round(iy_e-C(2)+1))+1);
                        p_rect_sel(1,2) = ilm_set_bound(iy_0, 1, ny);
                    else
                        iy_0 = p_rect_sel(1,2);
                        iy_e = round(ilc_pn_fact(round(C(2)-iy_0+1))+ iy_0-1);
                        p_rect_sel(2,2) = ilm_set_bound(iy_e, 1, ny);
                    end
                end

                children = get(axes_f(2), 'Children');
                delete(findobj(children, 'Type', 'Line'));
                fn_plot_rect_ax_f_2(p_rect_sel, 'f');
            end
        elseif(b_ax_f(3) && bb_shift_kpf)
            C = get(axes_f(3), 'CurrentPoint');
            radius = sqrt((C(1,1)-x_c)^2+(C(1,2)-y_c)^2);

            children = get(axes_f(3), 'Children');
            delete(findobj(children, 'Type', 'Line', '-and', 'Tag', 'm'));

            sigma_gt = str2double(ui_edt_sigma.String);
            sigma_rt = ilm_sigma_g_2_sigma_r(nx, ny, sigma_gt);
            
            radius = min(sigma_g_max-1, radius);
            radius = max(0.9*sigma_rt, radius);

            ilm_plot_circle(x_c, y_c, radius, 'green', 'm'); 
        end
    end

    function cb_mouse_click(source, event)
        bb_mouse_click = true;
        
        b_ax_f = ilm_gui_is_over_object(source, axes_f);
        
        if(b_ax_f(1))
            if(bb_shift_kpf)
                C = get(axes_f(1), 'CurrentPoint');
                sigma_gt = sqrt((C(1,1)-fs_x_c)^2+(C(1,2)-fs_y_c)^2);
                sigma_rt = ilm_sigma_g_2_sigma_r(nx, ny, sigma_gt);

                children = get(axes_f(1), 'Children');
                delete(findobj(children, 'Type', 'Line'));

                if(sigma_gt>sigma_g_max)
                    return
                end

                axes(axes_f(1));
                title(axes_f(1), ['sigma_g = ', num2str(sigma_gt, '%6.2f'), ' px. , sigma_r = ', num2str(sigma_rt, '%6.2f'), ' px.']);

                % set sigma
                ui_edt_sigma.String = num2str(sigma_gt, '%5.2f');

                % plot circle
                ilm_plot_circle(fs_x_c, fs_y_c, sigma_gt, 'red', 'f');

                cb_lb_data();
            end
        elseif(b_ax_f(2))
            C = get(axes_f(2), 'CurrentPoint');
            pm_0 = C(1,1:2);
        elseif(b_ax_f(3) && bb_shift_kpf)
            C = get(axes_f(3), 'CurrentPoint');
            radius = sqrt((C(1,1)-x_c)^2+(C(1,2)-y_c)^2);

            children = get(axes_f(3), 'Children');
            delete(findobj(children, 'Type', 'Line'));

            sigma_gt = str2double(ui_edt_sigma.String);
            sigma_rt = ilm_sigma_g_2_sigma_r(nx, ny, sigma_gt);
            
            radius = min(sigma_g_max-1, radius);
            radius = max(0.9*sigma_rt, radius);
            radius_f = radius/sigma_rt;
            
            % plot circle
            ilm_plot_circle(x_c, y_c, sigma_rt, 'blue', 'f'); 
            ilm_plot_circle(x_c, y_c, radius, 'red', 'f'); 
        end
    end

    function cb_mouse_release(source, event)
        bb_mouse_click = false;
        b_ax_f_2 = ilm_gui_is_over_object(source, axes_f(2));
        if(b_ax_f_2)
            if(ui_rb_move.Value)
                C = get(axes_f(2), 'CurrentPoint');
                dpm = C(1,1:2)-pm_0;
                
                if(bb_shift_kpf)
                    dpm(1) = 0;
                end
                
                ui_edt_x0.String = num2str(dpm(1));
                ui_edt_y0.String = num2str(dpm(2));
                if(abs(dpm(1))>=1 || (abs(dpm(2))>=1))
                    tmp_value = ui_cb_rcfft.Value;
                    ui_cb_rcfft.Value = 0;
                    cb_apply_tot_shift(source, event);
                    ui_cb_rcfft.Value = tmp_value;
                end
            end
        end
    end

    function cb_zoom(source, event)       
        fz = 1;
        if(event.VerticalScrollCount<0)
            fz = 1.5;
        elseif(event.VerticalScrollCount>0)
            fz = 1/1.5;
        end
        
        b_ax_f = ilm_gui_is_over_object(source, axes_f);

        if(b_ax_f(1))
            fz_t(1) = fz_t(1)*fz;            
            axes(axes_f(1));
            zoom(fz);
        elseif(b_ax_f(2))   
            fz_t(2) = fz_t(2)*fz; 
            axes(axes_f(2));
            zoom(fz);            
        elseif(b_ax_f(3))  
            fz_t(3) = fz_t(3)*fz; 
            axes(axes_f(3));
            zoom(fz);
        end
    end 

    function cb_press_key(obj, event)
        if(strcmpi(event.Key, 'delete'))
            
            b_ui_lb_data = ilm_gui_is_over_object(obj, ui_lb_data);
            if(b_ui_lb_data)
                fn_msn_start();

                ik_del = ui_lb_data.UserData{ui_lb_data.Value};
                data(:, :, ik_del) = [];
                n_data = ilm_nz_data(data);
                at_p(ik_del, :) = [];

                % fill in ui_lb_data
                fn_set_lb_at_p(at_p);
                ui_lb_data.Value = min(max(1, ik_del), n_data);

                % select item in ui_lb_data
                cb_lb_data();

                % plot fim
                fn_show_ax_f_1(ui_cb_rcfft.Value);

                fn_msn_end();
            end
        end
        
        bb_shift_kpf = strcmpi(event.Modifier, 'shift');
    end

    function cb_release_key(source, event)
        bb_shift_kpf = false;
    end

    function cb_close(source, event)
        b_stop = true;
        pause(0.1);
        delete(fh);        
    end
end

function data = fn_norm_data(data)
    p = 0.0;
    px_v_min = 2e-5;
    data = data - min(data(:));
    im_mean = mean(data(:));
    data = px_v_min*(data + p*im_mean)/((1+p)*im_mean);
end
    
function st_data = fn_set_input_data_alignment(system_conf, data, angles, at_p, p_rect_sel, btw_np)
    st_data.system_conf = system_conf;

    [ny, nx, n_data] = size(data);
    f_r = 256/max(nx, ny);
    if(nx>ny)
        size_r = [round(f_r*ny), 256, n_data];
    else
        size_r = [256, round(f_r*nx), n_data];
    end
    st_data.data_0 = fn_norm_data(imresize3(single(data), size_r));
    st_data.bg = min(reshape(st_data.data_0, [], n_data));

    [ny, nx, n_data] = size(st_data.data_0); 

    st_data.nx = nx;
    st_data.ny = nx;
    st_data.nz = ny;
    st_data.n_data = n_data;
    st_data.n_iter_f = 250;
    st_data.angles_d = angles;
    st_data.angles = angles*pi/180;
    st_data.f_r = f_r;
    st_data.n_iter = 4;
    st_data.opt_opt = 1;
    st_data.n_iter_opt = 35;
    st_data.n_iter_opt_sc = 35;
    st_data.n_iter_nm_tc = 5;
    st_data.n_iter_nm_theta = 12;
    st_data.n_iter_nm_tr = 10;
    st_data.bg_theta = 0.5;
    st_data.bb_n_theta = false;
    st_data.bg_tc = 0.5;
    st_data.bb_n_tc = false;
    st_data.tr = at_p(:, 5:6)*f_r;
    st_data.p_rc = [nx, ny]/2 - 0.5;
    st_data.theta = 0;
    st_data.dtheta = 1.0;
    st_data.txy = [0, 0];
    st_data.dtxy = [1.0, 0.0];
    st_data.dtx = 1.0;
    st_data.n_bg = 3;
    st_data.sigma_min = 2.0;
    st_data.sigma_max = 9;

    st_data.theta_min = -10;
    st_data.theta_max = 10;
    st_data.n_theta = st_data.theta_max-st_data.theta_min+1;
    st_data.theta_min_sft = st_data.theta_min-1;
    
    st_data.xc_min = -10;
    st_data.xc_max = 10;
    st_data.n_xc = st_data.xc_max-st_data.xc_min+1;

    st_data.bb_mask = false;
    rect_sel = round(f_r*p_rect_sel);
    rect_sel(:, 1) = ilm_set_bound(rect_sel(:, 1), 1, st_data.nx);
    rect_sel(:, 2) = ilm_set_bound(rect_sel(:, 2), 1, st_data.nz);
    st_data.rect_sel = rect_sel;
    st_data.ax = rect_sel(1, 1):rect_sel(2, 1);
    st_data.ay = rect_sel(1, 2):rect_sel(2, 2);
    tx = st_data.p_rc(1);
    radius_bw = max(abs(st_data.rect_sel(:, 1)-tx));

    ay_c = setdiff(1:st_data.nz, st_data.ay);
    st_data.data_fw = ilm_func_butterworth_rect(st_data.nx, st_data.nz, st_data.rect_sel, btw_np(1), btw_np(2));
%     st_data.data_fw(ay_c, :) = 0;

    radius = (radius_bw + st_data.nx/2)/2;
    st_data.vol_mask = ilm_cylindrical_mask(st_data.nx, st_data.ny, st_data.nz, radius, 1);
    st_data.vol_mask(:, :, ay_c) = 0;
end

function st_sirt = fn_create_sirt_pointers(st_data)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    vol_geom = astra_create_vol_geom(st_data.nx, st_data.ny, st_data.nz);
    proj_geom = astra_create_proj_geom('parallel3d', 1.0, 1.0, st_data.nz, st_data.nx, st_data.angles);

    proj_id = astra_mex_data3d('create', '-proj3d', proj_geom, permute(st_data.data, [2 3 1])); % [cols, angles, rows]
    rec_id = astra_mex_data3d('create', '-vol', vol_geom, 0);    
    if(st_data.bb_mask)
        mask_id = astra_mex_data3d('create', '-vol', vol_geom, st_data.vol_mask);
    end
    proj_fp_id = astra_mex_data3d('create', '-sino', proj_geom, 0);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    st_fp3d = astra_struct('FP3D_CUDA');
    st_fp3d.ProjectionDataId = proj_fp_id;
    st_fp3d.VolumeDataId = rec_id;

    alg_fp_id = astra_mex_algorithm('create', st_fp3d);   

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    st_sirt = astra_struct('SIRT3D_CUDA');  
    st_sirt.ProjectionDataId = proj_id;
    st_sirt.ReconstructionDataId = rec_id;
    st_sirt.bb_mask = st_data.bb_mask;
    if(st_sirt.bb_mask)
        st_sirt.option.ReconstructionMaskId = mask_id; 
    end
    st_sirt.option.MinConstraint = 0;

    alg_id = astra_mex_algorithm('create', st_sirt);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    st_sirt.alg_fp_id = alg_fp_id;    
    st_sirt.proj_fp_id = proj_fp_id;

    st_sirt.alg_id = alg_id;
    st_sirt.proj_id = proj_id;
    st_sirt.rec_id = rec_id;
    if(st_sirt.bb_mask)
        st_sirt.mask_id = mask_id;
    end 
    st_sirt.n_iter = st_data.n_iter_opt;
end

function fn_free_sirt_pointers(st_sirt)
    astra_mex_algorithm('delete', st_sirt.alg_fp_id);
    astra_mex_algorithm('delete', st_sirt.proj_fp_id);

    astra_mex_algorithm('delete', st_sirt.alg_id);
    astra_mex_data3d('delete', st_sirt.proj_id);    
    astra_mex_data3d('delete', st_sirt.rec_id);
    if(st_sirt.bb_mask)
        astra_mex_data3d('delete', st_sirt.mask_id);
    end

    astra_mex_data3d('clear');
end

function sc = fn_fd_sc_using_sirt(st_data)
    st_data.data = st_data.data_0;
    for ik=1:st_data.n_data
        data_ik = double(st_data.data(:, :, ik));
        data_ik = ilc_tr_2d(st_data.system_conf, data_ik, 1, 1, st_data.tr(ik, :), 1, 0);
        st_data.data(:, :, ik) = max(0, data_ik).*st_data.data_fw;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    st_sirt = fn_create_sirt_pointers(st_data);
    st_sirt.n_iter = st_data.n_iter_opt_sc;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    sc = ones(1, st_data.n_data);
    n_it = 3;
    for it=1:n_it
        astra_mex_data3d('set', st_sirt.rec_id, 0);
        astra_mex_data3d('set', st_sirt.proj_id, permute(st_data.data, [2 3 1]));
        if(st_sirt.bb_mask)
            astra_mex_data3d('set', st_sirt.mask_id, st_data.vol_mask);
        end
        astra_mex_algorithm('iterate', st_sirt.alg_id, st_sirt.n_iter);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        astra_mex_algorithm('iterate', st_sirt.alg_fp_id);
        data_proj = astra_mex_data3d('get_single', st_sirt.proj_fp_id);
        data_proj = permute(data_proj, [3 1 2]);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        sc_it = mean(reshape(data_proj, [], st_data.n_data), 1)./mean(reshape(st_data.data, [], st_data.n_data), 1);
        st_data.data = st_data.data.*reshape(sc_it, 1, 1, st_data.n_data);
        sc = sc.*sc_it;
        
%         for ik=1:n_data
%             figure(1); clf;
%             subplot(1,2, 1);
%             imagesc(st_data.data(:, :, ik));
%             axis image off;
%             subplot(1, 2, 2);
%             imagesc(data_proj(:, :, ik));
%             axis image off;              
%             pause(0.075);
%         end

        disp(['percentage = ', num2str(it*100/n_it, 3)])
    end
    
    figure(2); clf;
    plot(st_data.angles_d, sc, '-+r');
    title('Scaling vs. angles')
    xlabel('angles')
    ylabel('Scaling')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    fn_free_sirt_pointers(st_sirt);
end

function tx = fn_fd_tx_using_sirt(st_data)
    st_data.data = st_data.data_0;
    for ik=1:st_data.n_data
        data_ik = double(st_data.data(:, :, ik));
        data_ik = ilc_tr_2d(st_data.system_conf, data_ik, 1, 1, st_data.tr(ik, :), 1, 0);
        st_data.data(:, :, ik) = max(0, data_ik).*st_data.data_fw;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    st_sirt = fn_create_sirt_pointers(st_data);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tt = zeros(st_data.n_xc, 2);
    d_xc = (st_data.xc_max-st_data.xc_min+1)/st_data.n_xc;

    for ik=1:st_data.n_xc
        tt(ik, 1) = st_data.xc_min + (ik-1)*d_xc;
        tt(ik, 2) = fd_get_error_tx_using_sirt(st_data, st_sirt, tt(ik, 1));
        disp(['[', num2str(ik*100/st_data.n_xc, 3), ', ', num2str(tt(ik, 1), 2), ', ', num2str(tt(ik, 2), 5), ']'])
    end

    p = polyfit(tt(:, 1), tt(:, 2), 2);
    tx = -p(2)/(2*p(1));
    
    [~, ind] = min(tt(:, 2));
    tx_min = tt(ind, 1);
    
    if(abs(tx-tx_min)>d_xc)
        tx = d_xc;
    end
    
    tx =  tx/st_data.f_r;

    figure(2); clf;
    plot(tt(:, 1)/st_data.f_r, tt(:, 2), '-+');  
    title('Error vs. Translation')
    xlabel('Translation')
    ylabel('Error')

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    fn_free_sirt_pointers(st_sirt);
end

function ee = fd_get_error_tx_using_sirt(st_data, st_sirt, tx)
    txy = [tx, 0];
    data_loc = st_data.data;
    for ik_l=1:st_data.n_data
        data_ik = double(data_loc(:, :, ik_l));
        data_ik = ilc_tr_2d(st_data.system_conf, data_ik, 1, 1, txy, 6, 0);
        data_loc(:, :, ik_l) = max(0, data_ik);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    astra_mex_data3d('set', st_sirt.rec_id, 0);
    astra_mex_data3d('set', st_sirt.proj_id, permute(data_loc, [2 3 1]));

    if(st_sirt.bb_mask)
        astra_mex_data3d('set', st_sirt.mask_id, st_data.vol_mask);
    end

    astra_mex_algorithm('iterate', st_sirt.alg_id, st_sirt.n_iter);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    astra_mex_algorithm('iterate', st_sirt.alg_fp_id);
    data_proj = astra_mex_data3d('get_single', st_sirt.proj_fp_id);
    data_proj = permute(data_proj, [3 1 2]);

    data_proj = abs(data_proj - data_loc);
    ee = sum(data_proj(:));
end

function[theta] = ilm_fd_theta_using_sirt_3df(st_data)
    st_data.data = st_data.data_0;
    for ik=1:st_data.n_data
        data_ik = double(st_data.data(:, :, ik));
        data_ik = ilc_tr_2d(st_data.system_conf, data_ik, 1, 1, st_data.tr(ik, :), 1, 0);
        data_ik = max(0, data_ik).*st_data.data_fw;
        data_ik = ilc_rot_tr_2d(st_data.system_conf, data_ik, 1, 1, st_data.theta_min_sft, st_data.p_rc, [0, 0], 1, 0); 
        st_data.data(:, :, ik) = max(0, data_ik);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    st_sirt = fn_create_sirt_pointers(st_data);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tt = zeros(st_data.n_theta, 2);
    d_theta = (st_data.theta_max-st_data.theta_min+1)/st_data.n_theta;
    
    for ik=1:st_data.n_theta
        tt(ik, 1) = st_data.theta_min + (ik-1)*d_theta;
        tt(ik, 2) = fd_get_error_theta_using_sirt(st_data, st_sirt, tt(ik, 1));
        disp(['[', num2str(ik*100/st_data.n_theta, 3), ', ', num2str(tt(ik, 1), 2), ', ', num2str(tt(ik, 2), 5), ']'])
    end

    p = polyfit(tt(:, 1), tt(:, 2), 2);
    theta = -p(2)/(2*p(1));
    
    [~, ind] = min(tt(:, 2));
    theta_min = tt(ind, 1);
    
    if(abs(theta-theta_min)>d_theta)
        theta = theta_min;
    end

    figure(2); clf;
    plot(tt(:, 1), tt(:, 2), '-+');  
    title('Error vs. Theta')
    xlabel('Theta')
    ylabel('Error')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    fn_free_sirt_pointers(st_sirt);
end

function[ee] = fd_get_error_theta_using_sirt(st_data, st_sirt, theta)
    theta = theta - st_data.theta_min_sft;

    data_loc = st_data.data;
    for ik_l=1:st_data.n_data
        data_ik = double(data_loc(:, :, ik_l));
        data_ik = ilc_rot_tr_2d(st_data.system_conf, data_ik, 1, 1, theta, st_data.p_rc, [0, 0], 6, 0); 
        data_loc(:, :, ik_l) = max(0, data_ik);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    astra_mex_data3d('set', st_sirt.rec_id, 0);
    astra_mex_data3d('set', st_sirt.proj_id, permute(data_loc, [2 3 1]));

    if(st_sirt.bb_mask)
        astra_mex_data3d('set', st_sirt.mask_id, st_data.vol_mask);
    end

    astra_mex_algorithm('iterate', st_sirt.alg_id, st_sirt.n_iter);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    astra_mex_algorithm('iterate', st_sirt.alg_fp_id);
    data_proj = astra_mex_data3d('get_single', st_sirt.proj_fp_id);
    data_proj = permute(data_proj, [3 1 2]);

    data_proj = abs(data_proj - data_loc);
    ee = sum(data_proj(:));
end