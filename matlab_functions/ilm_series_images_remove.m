function[data] = ilm_series_images_remove(data_i)
    close all

    data = data_i;
    n_data = ilm_nz_data(data); 

    fy = 0.60;
    fx = 0.55;
    dm = get(0, 'MonitorPositions');
    dm = dm(1, :);
    w = fx*dm(3);
    h = fy*dm(4);
    x0 = (1-fx)*w/2;
    y0 = (1-fy)*h/2;

    fh = figure(1); clf;
    set(fh, {'Name', 'Visible', 'units', 'position', 'CloseRequestFcn'}, {'Frame removal -- Software created by Ivan Lobato: Ivanlh20@gmail.com', 'on', 'pixels', [x0, y0, x0+w, y0+h], @cb_close})
    movegui(fh, 'center');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ui_pn_opt = uipanel('Parent', fh, 'Title', 'Options', 'Units', 'normalized',...,
    'FontSize', 12, 'BackgroundColor', 'white', 'Position', [0.1 0.85 0.8 0.10]);
         
    pn_x_0 = 12;
    pn_y_1 = 10;
    pn_d = 4;    
    pn_h = 24;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pn_w = [90, 65, 55, 65, 55, 90, 150, 90];
    pn_n = length(pn_w);
    pn_x = pn_x_0*ones(1, pn_n);
    
    for ik=2:pn_n
        pn_x(ik) = pn_x(ik-1) + pn_d + pn_w(ik-1);
    end

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Reset data', 'Position', [pn_x(1) pn_y_1 pn_w(1) pn_h], 'Callback', @cb_reset_data);

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'Cmap', 'Position', [pn_x(2) pn_y_1 pn_w(2) pn_h]);

    ui_pu_cmap = uicontrol('Parent', ui_pn_opt, 'Style', 'popup',...
    'String', {'jet', 'hot', 'gray', 'hsv', 'parula', 'cool'}, 'Value', 2,...
    'Position', [pn_x(3) pn_y_1 pn_w(3) pn_h], 'Callback', @(src, ev)cb_lb_data); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'Time(s.)', 'Position', [pn_x(4) pn_y_1 pn_w(4) pn_h]);
    
    ui_edt_time = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.075', 'Position', [pn_x(5) pn_y_1 pn_w(5) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Show data', 'Position', [pn_x(6) pn_y_1 pn_w(6) pn_h], 'Callback', @(src, ev)fn_show_data);

    ui_txt_msg = uicontrol('Parent', ui_pn_opt, 'Style', 'text',...
    'String', '00.0%', 'Position', [pn_x(7) pn_y_1 pn_w(7) pn_h], 'FontSize', 13, 'FontWeight', 'bold');  

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'Close', 'Position', [pn_x(8) pn_y_1 pn_w(8) pn_h], 'Callback', @cb_close);  

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    d_f = 0.010;    
    h_f = 0.75;    
    w_1 = 0.10;
    w_2 = h_f*h/w;
    x_1 = (1-(w_1+w_2+d_f))/2;  
    x_2 = x_1+w_1+d_f; 
    y_0 = 0.05;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ui_lb_data = uicontrol('Style', 'listbox', 'Units', 'normalized',...
        'Position', [x_1 y_0 w_1 h_f], 'Callback', @cb_lb_data);
%     ui_lb_data.Units = 'pixels';
    ax_f(1) = axes('Position', [x_2 y_0 w_2 h_f], 'Visible', 'off'); 
    
    fh.WindowButtonMotionFcn = @cb_mouse_move;
    fh.WindowScrollWheelFcn = @cb_zoom_fimage;
    fh.WindowKeyPressFcn = @cb_press_key;

    % set initial zoom    
    fz_t(1) = 1;

    % set initial lb_data values
    fn_set_lb_data_0(n_data);
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

    function fn_set_lb_data_0(n_data)
        items{1, n_data} = [];
        UserData{1, n_data} = [];
        for ik=1:n_data
            items{ik} = ['Image # = ', num2str(ik, '%.3d')]; 
            UserData{ik} = ik;
        end
        ui_lb_data.String = items;
        ui_lb_data.UserData = UserData;        
    end

    function fn_plot_image(im_r, title_r)
        cmap = ui_pu_cmap.String{ui_pu_cmap.Value};
        
        axes(ax_f(1));
        imagesc(im_r);
        axis image off;
        colormap(cmap);
        title(title_r);
    end

    function fn_show_data()
        for ik=1:n_data
            im_r = data(:, :, ik);
            title_r = ['Image # ', num2str(ik)];
            fn_plot_image(im_r, title_r);

            ui_txt_msg.String =[ num2str(100*ik/n_data, '%4.1f'), ' %'];
            tm = str2double(ui_edt_time.String);
            tm = ilm_ifelse(isnan(tm), 0.075, tm);
            pause(tm);
        end 
    end

    function cb_reset_data(hobject, event)
        data = data_i;
        n_data = ilm_nz_data(data);

        % fill in ui_lb_data
        fn_set_lb_data_0(n_data);
            
        % select item in ui_lb_data
        cb_lb_data();    
    end

    function cb_lb_data(hobject, event)
        fn_msn_start();
        
        ik_r = ui_lb_data.UserData{ui_lb_data.Value};
        
        im_r = data(:, :, ik_r);
        title_r = ['Image # ', num2str(ik_r)];

        fn_plot_image(im_r, title_r);
        
        fn_msn_end();
    end 

    function cb_press_key(src, event)
        if(strcmpi(event.Key, 'delete'))
            
            b_ui_lb_data = ilm_gui_is_over_object(src, ui_lb_data);
            if(~b_ui_lb_data)
                return
            end  

            fn_msn_start();
            
            ik_del = ui_lb_data.UserData{ui_lb_data.Value};
            data(:, :, ik_del) = [];
            n_data = ilm_nz_data(data);
            
            % fill in ui_lb_data
            fn_set_lb_data_0(n_data);
            
            ui_lb_data.Value = min(max(1, ik_del), n_data);
            
            % select item in ui_lb_data
            cb_lb_data();
            
            fn_msn_end();
        end
    end

    function cb_close(hobject, event)
        delete(fh);        
    end

    function cb_mouse_move(hobject, event)
        
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
        end
    end 
end