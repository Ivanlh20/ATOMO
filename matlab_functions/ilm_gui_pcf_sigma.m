function[sigma_g] = ilm_gui_pcf_sigma(system_conf, fim, im_r, im_s)
    global bb_pcf im_rg im_sg 
    global f_xy fs_ax fs_ay fs_x_c fs_y_c
    
    close all
    
    bb_pcf = nargin == 4;
    [ny, nx] = size(fim);
    
    im_rg = 0;
    im_sg = 0;
    if(bb_pcf)
        im_rg = double(im_r);
        im_sg = double(im_s);
    end
    
    if(nx>ny)
        f_xy = [1, nx/ny];
    else
        f_xy = [ny/nx, 1];
    end
    
    fs_ax = (1:nx)*f_xy(1);
    fs_ay = (1:ny)*f_xy(2);
    
    fs_x_c = nx*f_xy(1)/2 + 1;
    fs_y_c = ny*f_xy(2)/2 + 1;
    
    sigma_g_max = min([nx/2, ny/2].*f_xy)-1;

    fy = 0.60;
    fx = 0.75;
    dm = get(0, 'MonitorPositions');
    dm = dm(1, :);
    w = fx*dm(3);
    h = fy*dm(4);
    x0 = (1-fx)*w/2;
    y0 = (1-fy)*h/2;
 
    fh = figure(1); clf;
    set(fh, {'Name', 'Visible', 'units', 'position', 'CloseRequestFcn'}, {'g_max', 'on', 'pixels',[x0, y0, x0+w, y0+h], @cb_close})
    movegui(fh, 'center');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ui_pn_opt = uipanel('Parent', fh, 'Title', '', 'Units', 'normalized',...,
    'FontSize', 12, 'BackgroundColor', 'white', 'Position', [0.05 0.9 0.9 0.085]);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pn_y_1 = 12;  
    pn_w_0 = 90;
    pn_d = 4;    
    pn_h = 24;
    
    pn_n = 3;    
    pn_w = pn_w_0*ones(1, pn_n);

    pn_x_0 = round((w - pn_w_0*pn_n+(pn_n-1)*pn_d)/2);    
    pn_x = pn_x_0*ones(1, pn_n);
    
    pn_w(1:3) = [90, 90, 90];
    for ik=2:pn_n
        pn_x(ik) = pn_x(ik-1) + pn_d + pn_w(ik-1);
    end
    
    uicontrol('Parent', ui_pn_opt, 'Style', 'text',...
    'String', 'Sigma_g(px.)', 'Position', [pn_x(1) pn_y_1 pn_w(1) pn_h]);
    
    ui_edt_sigma = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',...
    'String', num2str(sigma_g_max/2, '%5.2f'), 'Position', [pn_x(2) pn_y_1 pn_w(2) pn_h]);     
    
    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'Close', 'Position', [pn_x(3) pn_y_1 pn_w(3) pn_h], 'Callback', @cb_close);  

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    d_f = 0.010;    
    y_0 = 0.05;
    if(bb_pcf)
        h_f = 0.75;
        w_1 = 0.475;
        w_2 = 0.475;        
        x_1 = (1-(w_1+w_2+d_f))/2;  
        x_2 = x_1+w_1+d_f;  
        axes_f(1) = axes('Position', [x_1 y_0 w_1 h_f], 'Visible', 'off');         
        axes_f(2) = axes('Position', [x_2 y_0 w_2 h_f], 'Visible', 'off'); 
    else         
        h_f = 0.75;
        w_1 = 0.75;
        x_1 = (1-w_1)/2;      
        axes_f(1) = axes('Position', [x_1 y_0 w_1 h_f], 'Visible', 'off'); 
    end

    fh.WindowButtonMotionFcn = @cb_mouse_move;
    fh.WindowButtonDownFcn = @cb_mouse_click;
    fh.WindowScrollWheelFcn = @cb_zoom;
    
    % set initial sigma
    [ny, nx] = size(fim);
    sigma_gt = ilc_info_limit_2d(fim);
    ui_edt_sigma.String = num2str(sigma_gt, '%5.2f');
    
    % set initial zoom    
    fz_t(1) = sigma_g_max/(2*ilc_info_limit_2d(fim));
    fz_t(2) = 1;
    
    % plot fim
    fn_show_fim();
        
    uiwait(fh)

    function[im] = fn_rescale_img(im_i, alpha)
        if(nargin<2)
            alpha = 0.125;
        end
        alpha = max(0.01, abs(alpha));
        im = abs(im_i).^alpha;      
    end

    function fn_show_fim()
        % set axes
        axes(axes_f(1));
        imagesc(fs_ax, fs_ay, fn_rescale_img(fim));  
        axis image off;
        colormap hot; 
        zoom(fz_t(1));
    end

    function cb_close(source, event)
        sigma_g = str2double(ui_edt_sigma.String);
        delete(fh);        
    end

    function fn_show_pcf(source, event)
        sigma_gt = str2double(ui_edt_sigma.String);      
        if(sigma_gt>sigma_g_max)
            return
        end
        
        A = [1 0; 0 1];
        txy = [0, 0];        
        pcf = ilc_pcf_2d(system_conf, im_rg, im_sg, 1, 1, A, txy, 0.05, sigma_gt); 
        
        axes(axes_f(2));
        imagesc(pcf);
        axis image off;
        colormap hot;
        zoom(fz_t(2));
    end 

    function cb_mouse_move(source, event)
        axes(axes_f(1));
        b_ax_f_1 = ilm_gui_is_over_object(source, axes_f(1));
        if(~b_ax_f_1)
            return
        end
        
        C = get(axes_f(1), 'CurrentPoint');
        sigma_gt = sqrt((C(1,1)-fs_x_c)^2+(C(1,2)-fs_y_c)^2);
        sigma_rt = ilm_sigma_g_2_sigma_r(nx, ny, sigma_gt);
        
        children = get(axes_f(1), 'Children');
        delete(findobj(children, 'Type', 'Line'));
        
        axes(axes_f(1));
        title(axes_f(1), ['sigma_g = ', num2str(sigma_gt, '%6.2f'), ' px. , sigma_r = ', num2str(sigma_rt, '%6.2f'), ' px.']);

        % plot circle
        ilm_plot_circle(fs_x_c, fs_y_c, sigma_gt, 'green');
        
        % plot selected circle
        sigma_gt = str2double(ui_edt_sigma.String);
        ilm_plot_circle(fs_x_c, fs_y_c, sigma_gt, 'red');      
    end

    function cb_mouse_click(source, event)
        b_ax_f_1 = ilm_gui_is_over_object(source, axes_f(1));
        if(~b_ax_f_1)
            return
        end
        
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
        ilm_plot_circle(fs_x_c, fs_y_c, sigma_gt, 'red');

        if(bb_pcf)
            fn_show_pcf();
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
        elseif(bb_pcf && b_ax_f(2))   
            fz_t(2) = fz_t(2)*fz; 
            axes(axes_f(2));
            zoom(fz);
        end
    end 
end