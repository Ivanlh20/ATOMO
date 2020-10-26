function[data, points] = ilm_series_images_filtering(data_i, points_i, fimage_i)
    close all

    data = data_i;
    n_data = length(data);

    if(nargin<2)
        points_i = [];
    end   
    points = points_i;
    
    [ny, nx, n_data] = ilm_size_data(data);
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
         
    pn_x_0 = 12;
    pn_y_1 = 10;
    pn_d = 4;    
    pn_h = 24;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pn_w = [65, 45, 35, 50, 35, 60, 55, 50, 65, 55, 90, 90, 90, 90, 90, 100, 90];
    pn_n = length(pn_w);
    pn_x = pn_x_0*ones(1, pn_n);
    
    for ik=2:pn_n
        pn_x(ik) = pn_x(ik-1) + pn_d + pn_w(ik-1);
    end

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',...
    'String', 'radius', 'Position', [pn_x(1) pn_y_1 pn_w(1) pn_h]);
    
    edt_radius = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',...
    'String', '5', 'Position', [pn_x(2) pn_y_1 pn_w(2) pn_h]);
    
    uicontrol('Parent', ui_pn_opt, 'Style', 'text',...
    'String', 'x', 'Position', [pn_x(3) pn_y_1 pn_w(3) pn_h]);
    
    ui_edt_x = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',...
    'String', num2str(x_c), 'Position', [pn_x(4) pn_y_1 pn_w(4) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',...
    'String', 'y', 'Position', [pn_x(5) pn_y_1 pn_w(5) pn_h]);
    
    ui_edt_y = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',...
    'String', num2str(y_c), 'Position', [pn_x(6) pn_y_1 pn_w(6) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',...
    'String', 'Exp. FFT', 'Position', [pn_x(7) pn_y_1 pn_w(7) pn_h]);
    
    ui_pu_exp = uicontrol('Parent', ui_pn_opt, 'Style', 'popup',...
    'String', {'0.100', '0.125', '0.20', '0.25', '0.5', '0.75'}, 'Value', 3,...
    'Position', [pn_x(8) pn_y_1 pn_w(8) pn_h], 'Callback', @cb_change_exp); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'Time(s.)', 'Position', [pn_x(9) pn_y_1 pn_w(9) pn_h]);
    
    ui_edt_time = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.075', 'Position', [pn_x(10) pn_y_1 pn_w(10) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Show data', 'Position', [pn_x(11) pn_y_1 pn_w(11) pn_h], 'Callback', @cb_show_data);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Remove', 'Position', [pn_x(12) pn_y_1 pn_w(12) pn_h], 'Callback', @cb_remove);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Keep', 'Position', [pn_x(13) pn_y_1 pn_w(13) pn_h], 'Callback', @cb_keep);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Reset data', 'Position', [pn_x(14) pn_y_1 pn_w(14) pn_h], 'Callback', @cb_reset_data);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'Reset points', 'Position', [pn_x(15) pn_y_1 pn_w(15) pn_h], 'Callback', @cb_reset_points);

    ui_txt_msg = uicontrol('Parent', ui_pn_opt, 'Style', 'text',...
    'String', '00.0%', 'Position', [pn_x(16) pn_y_1 pn_w(16) pn_h], 'FontSize', 13, 'FontWeight', 'bold');  

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'Close', 'Position', [pn_x(17) pn_y_1 pn_w(17) pn_h], 'Callback', @cb_close);  

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
    
    if(nargin<3)
        fimage = ilm_mean_abs_fdata(data);
    else
        fimage = fimage_i;
    end    
       
    % set initial zoom    
    fz_t1 = sigma_g_max/(2*ilc_info_limit_2d(fimage));
    
    % plot fimage
    fn_show_ax_f_1(false);
    fn_plot_image_ik(1);
    fn_lb_data(points);   
    
    uiwait(fh)
    
    function cb_change_exp(obj, event)
        fn_show_ax_f_1(false);
        fn_plot_circles_f();
    end

    function fn_show_ax_f_1(b_fimage_rc)
        if(nargin==0)
            b_fimage_rc = true;
        end
        
        if(b_fimage_rc)
            if(nargin<3)
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
        alpha = str2double(ui_pu_exp.String{ui_pu_exp.Value});
        if(~isnumeric(alpha))
            alpha = 0.20;
        end
        
        alpha = max(0.01, abs(alpha));
        
        im = abs(im_i).^alpha;      
    end

    function fn_plot_symm_circles(x_1, y_1, radius, color, tag)
        t_h = 0:pi/50:2*pi;
        x_t = radius*cos(t_h);
        y_t = radius*sin(t_h); 
        lo = line(x_t + x_1, y_t + y_1, 'LineWidth', 2, 'Color', color);  
        lo.Tag = tag;
        
        x_2 = 2*x_c-x_1;
        y_2 = 2*y_c-y_1;
        lo = line(x_t + x_2, y_t + y_2, 'LineWidth', 2, 'Color', color);
        lo.Tag = tag;
    end

    function fn_plot_circles_f()
        n_points = size(points);
        for ip=1:n_points
            x_1 = points(ip, 1);
            y_1 = points(ip, 2);
            radius = points(ip, 3);   
            
            fn_plot_symm_circles(x_1, y_1, radius, 'red', 'f')
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
        imagesc(abs(data(:, :, ik)));
        axis image off;
        colormap jet;
        title(['Image # ', num2str(ik)]);
    end

    function[] = fn_lb_data(points)
        n_points = size(points);
        items = {};
        for ip=1:n_points
            items{ip} = [num2str(points(ip, 1), '%5.2f'), ', ', num2str(points(ip, 2), '%5.2f'), ', ', num2str(points(ip, 3), '%5.2f')];
        end

        ui_lb_data.String = items; 
    end

    function fn_show_data()
        for ik=1:n_data
            fn_plot_image_ik(ik);
            
            tm = str2double(ui_edt_time.String);
            tm = ilm_ifelse(isnan(tm), 0.125, tm);
            pause(tm);
        end 
    end

    function cb_remove(obj, event)
        ui_txt_msg.String = 'Processing';
        drawnow
        
        data = ilm_remove_points_fourier_space(data_i, points, Rx, Ry);
        
        fn_show_ax_f_1();
        fn_show_data(); 
        
        ui_txt_msg.String = 'Done';
    end

    function cb_keep(obj, event)
        ui_txt_msg.String = 'Processing';
        drawnow
        
        n_points = size(points);
        mask = zeros(ny, nx);
        
        for ip=1:n_points
            x_1 = points(ip, 1);
            y_1 = points(ip, 2);
            x_2 = 2*x_c-x_1;
            y_2 = 2*y_c-y_1;
            d = points(ip, 3);
            d2 = d^2;
            alpha = pi/(2*d);
            beta = 0.5*pi;
            R_1 = (Rx-x_1).^2+(Ry-y_1).^2;
            R_2 = (Rx-x_2).^2+(Ry-y_2).^2;
            ii = find(R_1<d2);
            mask(ii) = sin(alpha*sqrt(R_1(ii))+beta).^2;
            ii = find(R_2<d2);
            mask(ii) = sin(alpha*sqrt(R_2(ii))+beta).^2;
        end
        
        for ik=1:n_data
            fim = ifftshift(fft2(data_i(:, :, ik)));
            fim = fim.*mask;
            data(:, :, ik) = ifft2(fftshift(fim));
        end
        
        fn_show_ax_f_1();
        fn_show_data(); 
        
        ui_txt_msg.String = 'Done';
    end

    function cb_reset_data(hobject, event)
        data = data_i;
        fn_show_ax_f_1();
        fn_show_data();
        % plot all fix circles
        fn_plot_circles_f();
    end

    function cb_reset_points(hobject, event)
        points = points_i;
        fn_lb_data(points);
        
        fn_show_ax_f_1();
        fn_show_data();
        % plot all fix circles
        fn_plot_circles_f();
    end

    function cb_close(hobject, event)
        for ik=1:n_data
            data(:, :, ik) = max(0, real(data(:, :, ik)));
%             data(:, :, ik) = real(data(:, :, ik));
        end         
        delete(fh);        
    end

    function cb_show_data(hobject, event)
        ui_txt_msg.String = 'Processing';
        drawnow
        
        fn_show_data();
        
        ui_txt_msg.String = 'Done';
    end

    function [bb]=is_new_point(x, y, points)
        bb = true;
        if(size(points, 1)>0)
            d2 = 0.5^2;
            bb = isempty(find(sum((points(:, 1:2)-[x, y]).^2, 2)<d2, 1));
        end
    end

    function cb_press_key(obj, event)
        if(strcmpi(event.Key, 'delete'))
            if(fn_is_over_object(obj, ax_f(1)))
                x = str2double(ui_edt_x.String);
                y = str2double(ui_edt_y.String);
                if(is_new_point(x, y, points))
                    radius = str2double(edt_radius.String);
                    points = [points; x y radius];
                    % add to the plot a fix circle
                    fn_plot_symm_circles(x, y, radius, 'red', 'f');
                end
                
            elseif(fn_is_over_object(obj, ui_lb_data))
                points(ui_lb_data.Value, :) = [];
                % plot all fix circles
                fn_plot_circles_f();
            end
            fn_lb_data(points);
        
        elseif(strcmpi(event.Character, '+'))  
            edt_radius.String = num2str(str2double(edt_radius.String)+1);  
        elseif(strcmpi(event.Character, '-'))  
            edt_radius.String = num2str(max(str2double(edt_radius.String)-1, 1));
        end
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
        delete(findobj(children, 'Type', 'Line', '-and', 'Tag', 'm'));
        
        axes(ax_f(1));
        title(ax_f(1), ['radius = ', num2str(radius, '%6.2f')]);

        % plot circle
        x_1 = C(1,1);
        y_1 = C(1, 2);  
        
        fn_plot_symm_circles(x_1, y_1, radius, 'green', 'm');
        
%         % plot selected circle
%         fn_plot_circles_f();
    end

    function cb_mouse_click(hobject, event)
        b_ax_f_1 = fn_is_over_object(hobject, ax_f(1));
        if(~b_ax_f_1)
            return
        end
        
        C = get(ax_f(1), 'CurrentPoint');
        radius = str2double(edt_radius.String);
        
        x_1 = C(1,1);
        y_1 = C(1,2);

        ii = (Rx-x_1).^2+(Ry-y_1).^2<=radius^2;
        [~, idx] = max(fimage(:).*ii(:));
        [y_1, x_1] = ind2sub(size(fimage), idx);

        ii = find((Rx-x_1).^2+(Ry-y_1).^2<=radius^2);
        im_s = sum(fimage(ii));
        x_1 = sum(fimage(ii).*Rx(ii))/im_s;
        y_1 = sum(fimage(ii).*Ry(ii))/im_s;
        
        ui_edt_x.String = num2str(x_1);
        ui_edt_y.String = num2str(y_1);

        children = get(ax_f(1), 'Children');
        delete(findobj(children, 'Type', 'Line', '-and', 'Tag', 'm'));
        
        axes(ax_f(1));
        title(['radius = ', num2str(radius, '%6.2f')]);

        % plot selected circle
        fn_plot_symm_circles(x_1, y_1, radius, 'red' , 'm');
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