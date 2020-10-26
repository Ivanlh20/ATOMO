function[g_max] = ilm_gui_g_max(data, fimage_i)
    close all
    n_data = length(data);
    points = [];
    
    [ny, nx] = size(data(1).image);
    x_c = nx/2 + 1;
    y_c = ny/2 + 1;
    sigma_g_max = min(nx/2, ny/2);
    
    [Rx, Ry] = meshgrid(1:nx, 1:ny);
    
    fy = 0.60;
    fx = 0.75;
    dm = get(0, 'MonitorPositions');
    dm = dm(1, :);
    w = fx*dm(3);
    h = fy*dm(4);
    x0 = (1-fx)*w/2;
    y0 = (1-fy)*h/2;

    fh = figure(1); clf;
    set(fh, {'Name', 'Visible', 'units', 'position', 'CloseRequestFcn'}, {'Image filtering', 'on', 'pixels',[x0, y0, x0+w, y0+h], @cb_close})
    movegui(fh, 'center');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ui_pn_opt = uipanel('Parent', fh, 'Title', 'Options', 'Units', 'normalized',...,
    'FontSize', 12, 'BackgroundColor', 'white', 'Position', [0.1 0.85 0.8 0.10]);
         
    pn_n = 13;
    
    pn_y_1 = 10;
    pn_d = 4;    
    pn_h = 24;
    pn_w = 95*ones(1, pn_n);
    pn_x = ones(1, pn_n);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pn_x(1) = 20;
    for ik=2:pn_n
        pn_x(ik) = pn_x(ik-1) + pn_d + pn_w(ik-1);
    end
    
    uicontrol('Parent', ui_pn_opt, 'Style', 'text',...
    'String', 'radius', 'Position', [pn_x(1) pn_y_1 pn_w(1) pn_h]);
    
    edt_radius = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',...
    'String', '5', 'Position', [pn_x(2) pn_y_1 pn_w(2) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'Close', 'Position', [pn_x(13) pn_y_1 pn_w(13) pn_h], 'Callback', @cb_close);  

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    d_f = 0.010;    
    h_f = 0.75;    
    w_1 = 0.16;
    w_2 = h_f*h/w;
    w_3 = w_2;
    x_1 = (1-(w_1+w_2+w_3+2*d_f))/2;  
    x_2 = x_1+w_1+d_f; 
    x_3 = x_2+w_2+d_f;
    y_0 = 0.05;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ui_lb_data = uicontrol('Style', 'listbox', 'Units', 'normalized',...
        'Position', [x_1 y_0 w_1 h_f], 'Callback', @cb_lb_data);
    
    
    ax_f(1) = axes('Position', [x_2 y_0 w_2 h_f], 'Visible', 'off'); 
    ax_f(2) = axes('Position', [x_3 y_0 w_3 h_f], 'Visible', 'off'); 
    
    fh.WindowButtonMotionFcn = @cb_mouse_move;
    fh.WindowButtonDownFcn = @cb_mouse_click;
    fh.WindowScrollWheelFcn = @cb_zoom_fimage;
    fh.WindowKeyPressFcn = @cb_press_key;

    % set initial sigma
    if(nargin<2)
        fimage = ilm_mean_abs_fdata(data);
    else
        fimage = fimage_i;
    end   

    % set initial zoom    
    fz_t1 = sigma_g_max/(2*ilc_info_limit_2d(fimage));
    
    % plot fimage
    fn_show_ax_f_1(false);
    fn_plot_image_ik(1);
    
    uiwait(fh)
    
    function fn_show_ax_f_1(b_fimage_rc)
        if(nargin==0)
            b_fimage_rc = true;
        end
        
        if(b_fimage_rc)
            if(nargin<2)
                fimage = ilm_mean_abs_fdata(data);
            else
                fimage = fimage_i;
            end   
        end
        
        % set axes
        axes(ax_f(1));
        
        % plot fimage
        imagesc(fn_rescale_img(fimage));
        axis image off;
        colormap jet;  

        zoom(fz_t1);
    end

    function[im] = fn_rescale_img(im_i)
        im = abs(im_i).^0.10;      
    end

    function fn_plot_two_circles(x_1, y_1, x_2, y_2, radius, color)
        ilm_plot_circle(x_1, y_1, radius, color);  
        ilm_plot_circle(x_2, y_2, radius, color);  
    end

    function fn_plot_circles()
        n_points = size(points);
        for ip=1:n_points
            x_1 = points(ip, 1);
            y_1 = points(ip, 2);
            x_2 = 2*x_c-x_1;
            y_2 = 2*y_c-y_1;
            radius = points(ip, 3);   
            
            ilm_plot_circle(x_1, y_1, radius, 'red');  
            ilm_plot_circle(x_2, y_2, radius, 'red');  
        end
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

    function fn_plot_image_ik(ik)
        axes(ax_f(2));
        imagesc(abs(data(ik).image));
        axis image off;
        colormap jet;
        title(['Image # ', num2str(ik)]);
    end

    function fn_show_data()
        for ik=1:n_data
            fn_plot_image_ik(ik);
            
            tm = str2double(ui_edt_time.String);
            tm = ilm_ifelse(isnan(tm), 0.125, tm);
            pause(tm);
        end 
    end

    function cb_delete(obj, event)
        ui_txt_msg.String = 'Processing';
        drawnow
        
        n_points = size(points);
        mask = zeros(ny, nx, 'logical');
        
        for ip=1:n_points
            x_1 = points(ip, 1);
            y_1 = points(ip, 2);
            x_2 = 2*x_c-x_1;
            y_2 = 2*y_c-y_1;
            
            d2 = points(ip, 3)^2;
            
            mask = mask|((Rx-x_1).^2+(Ry-y_1).^2<d2)|((Rx-x_2).^2+(Ry-y_2).^2<d2);
        end
        
        for ik=1:n_data
            fim = ifftshift(fft2(data(ik).image));
            fim(mask) = 0;
            data(ik).image = ifft2(fftshift(fim));
        end
        
        fn_show_ax_f_1();
        fn_show_data(); 
        
        ui_txt_msg.String = 'Done';
    end

    function cb_reset_data(hobject, event)
        data = data;
        ui_lb_data.String = {};
        points = [];
    end

    function cb_press_key(obj, event)
        if(strcmpi(event.Key, 'delete'))
            if(fn_is_over_object(obj, ax_f(1)))
                x = str2double(ui_edt_x.String);
                y = str2double(ui_edt_y.String);
                radius = str2double(edt_radius.String);

                points = [points; x y radius];
            elseif(fn_is_over_object(obj, ui_lb_data))
                points(ui_lb_data.Value, :) = [];
            end
            
            n_points = size(points);
            for ip=1:n_points
                items{ip} = [num2str(points(ip, 1), '%5.2f'), ', ', num2str(points(ip, 2), '%5.2f'), ', ', num2str(points(ip, 3), '%5.2f')];
            end
            ui_lb_data.String = items; 
        
        elseif(strcmpi(event.Character, '+'))  
            edt_radius.String = num2str(str2double(edt_radius.String)+1);  
        elseif(strcmpi(event.Character, '-'))  
            edt_radius.String = num2str(max(str2double(edt_radius.String)-1, 1));
        end
    end

    function cb_close(hobject, event)
        for ik=1:n_data
            data(ik).image = max(0, data(ik).image);
        end         
        delete(fh);        
    end

    function cb_show_data(hobject, event)
        ui_txt_msg.String = 'Processing';
        drawnow
        
        fn_show_data();
        
        ui_txt_msg.String = 'Done';
    end

    function cb_mouse_move(hobject, event)
        axes(ax_f(1));
        b_ax_f_1 = fn_is_over_object(hobject, ax_f(1));
        if(~b_ax_f_1)
            return
        end
        
        radius = str2double(edt_radius.String);
        
        C = get(ax_f(1), 'CurrentPoint');
        
        children = get(ax_f(1), 'Children');
        delete(findobj(children, 'Type', 'Line'));
        
        axes(ax_f(1));
        title(ax_f(1), ['radius = ', num2str(radius, '%6.2f')]);

        % plot circle
        x_1 = C(1,1);
        y_1 = C(1, 2);
        x_2 = 2*x_c-x_1;
        y_2 = 2*y_c-y_1;    
        
        fn_plot_two_circles(x_1, y_1, x_2, y_2, radius, 'green');
        
        % plot selected circle
        fn_plot_circles();
    end

    function cb_mouse_click(hobject, event)
        b_ax_f_1 = fn_is_over_object(hobject, ax_f(1));
        if(~b_ax_f_1)
            return
        end
        
        C = get(ax_f(1), 'CurrentPoint');
        ui_edt_x.String = num2str(C(1,1));
        ui_edt_y.String = num2str(C(1,2));

        children = get(ax_f(1), 'Children');
        delete(findobj(children, 'Type', 'Line'));
        
        axes(ax_f(1));
        radius = str2double(edt_radius.String);
        title(['radius = ', num2str(radius, '%6.2f')]);

        % plot selected circle
        x_1 = str2double(ui_edt_x.String);
        y_1 = str2double(ui_edt_y.String);
        x_2 = 2*x_c-x_1;
        y_2 = 2*y_c-y_1; 
        
        fn_plot_two_circles(x_1, y_1, x_2, y_2, radius, 'red');
    end

    function cb_zoom_fimage(hobject, event)       
        fz = 1;
        if(event.VerticalScrollCount<0)
            fz = 1.5;
        elseif(event.VerticalScrollCount>0)
            fz = 1/1.5;
        end
        
        if(fn_is_over_object(hobject, ax_f(1)))
            fz_t1 = fz_t1*fz;            
            axes(ax_f(1));
            zoom(fz);
        elseif(fn_is_over_object(hobject, ax_f(2)))         
            axes(ax_f(2));
            zoom(fz);
        end
    end 
end