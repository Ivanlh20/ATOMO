function[im_r, theta] = ilm_gui_rotate_image(system_conf, im_i, bg_opt, bg)
    global rect_sel p_c nx ny
    
    close all

    if(nargin<4)
        bg = 0;
    end

    if(nargin<3)
        bg_opt = 1;
    end

    fy = 0.60;
    fx = 0.50;
    dm = get(0, 'MonitorPositions');
    dm = dm(1, :);
    w = fx*dm(3);
    h = fy*dm(4);
    x0 = (1-fx)*w/2;
    y0 = (1-fy)*h/2;

    fh = figure(1); clf;
    set(fh, {'Name', 'Visible', 'units', 'position', 'CloseRequestFcn'}, {'Rotate image -- Software created by Ivan Lobato: Ivanlh20@gmail.com ', 'on', 'pixels',[x0, y0, x0+w, y0+h], @cb_close})
    movegui(fh, 'center');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ui_pn_opt = uipanel('Parent', fh, 'Title', 'Options', 'Units', 'normalized',...,
    'FontSize', 12, 'BackgroundColor', 'white', 'Position', [0.05 0.90 0.85 0.095]);

    pn_x_0 = 12;
    pn_y_1 = 10;
    pn_d = 4;    
    pn_h = 24;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pn_w = [75, 50, 65, 150, 50, 65, 50];
    pn_n = length(pn_w);
    pn_x = pn_x_0*ones(1, pn_n);
    
    for ik=2:pn_n
        pn_x(ik) = pn_x(ik-1) + pn_d + pn_w(ik-1);
    end

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'Set rect.', 'Position', [pn_x(1) pn_y_1 pn_w(1) pn_h], 'Callback', @cb_set_rect); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'theta', 'Position', [pn_x(2) pn_y_1 pn_w(2) pn_h]);

    ui_edt_theta = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.0', 'Position', [pn_x(3) pn_y_1 pn_w(3) pn_h]);

    ui_sl_thr = uicontrol('Parent', ui_pn_opt, 'Style', 'slider',...
        'Min', -100, 'Max', 100, 'Value', 0, 'SliderStep', [1/79, 0.1], ...
        'Position', [pn_x(4) pn_y_1 pn_w(4) pn_h], 'Callback', @(src, ev)cb_slider_theta()); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'inc.', 'Position', [pn_x(5) pn_y_1 pn_w(5) pn_h]);

    ui_edt_dtheta = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.20', 'Position', [pn_x(6) pn_y_1 pn_w(6) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton', 'String', 'Close',...
        'Position', [pn_x(7) pn_y_1 pn_w(7) pn_h], 'Callback', @cb_close);
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h_f = 0.85;    
    w_1 = h_f*h/w;
  
    x_1 = (1-w_1)/2;  
    y_0 = 0.01;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax_f(1) = axes('Position', [x_1 y_0 w_1 h_f], 'Visible', 'off'); 
    
    fn_init(im_i);
    
%     fh.WindowButtonMotionFcn = @cb_mouse_move;
%     fh.WindowButtonDownFcn = @cb_mouse_click;
%     fh.WindowButtonUpFcn = @cb_mouse_release;
%     fh.WindowScrollWheelFcn = @cb_zoom;
%     fh.WindowKeyPressFcn = @cb_press_key;
%     fh.WindowKeyReleaseFcn = @cb_release_key;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    uiwait(fh)
    

    function cb_set_rect(source, event)
        title('select rectangle');
        rect_sel = cumsum(reshape(round(getrect), 2, 2).', 1);
        rect_sel(:, 1) = ilm_set_bound(rect_sel(:, 1), 1, nx);
        rect_sel(:, 2) = ilm_set_bound(rect_sel(:, 2), 1, ny);
        rect_sel(:, 2) = [1, ny].';
        
        children = get(ax_f(1), 'Children');
        delete(findobj(children, 'Type', 'Line'));
        
        ilm_plot_rectangle(rect_sel, 'r', 'f');
    end

    function fn_init(im_i)
        im_r = im_i;
        [ny, nx] = size(im_i);
        p_c = [nx/2 + 1, ny/2 + 1];
        rect_sel = [1, 1; nx, ny];
        
        fn_draw_data_ax_1();
        
        children = get(ax_f(1), 'Children');
        delete(findobj(children, 'Type', 'Line'));
        
        ilm_plot_rectangle(rect_sel, 'r', 'f');
    end

    function cb_slider_theta(src, ev)
        theta = str2double(ui_edt_theta.String);
        dtheta = sign(ui_sl_thr.Value)*str2double(ui_edt_dtheta.String);
        ui_sl_thr.Value = 0;
        theta = theta + dtheta;
        ui_edt_theta.String = num2str(theta, '%4.2f');
        
        im_r = fn_rotate_im(theta);
        
        fn_draw_data_ax_1();
        
        children = get(ax_f(1), 'Children');
        delete(findobj(children, 'Type', 'Line'));
        
        ilm_plot_rectangle(rect_sel, 'r', 'f');
    end

    function [im_r]=fn_rotate_im(theta)
        txy = [0 0];
        im_r = ilc_rot_tr_2d(system_conf, double(im_i), 1, 1, theta, p_c, txy, bg_opt, bg);

    end

    function fn_draw_data_ax_1()
        axes(ax_f(1));
        imagesc(im_r);
        axis image off;
        colormap gray;
    end

    function cb_close(source, event)
        delete(fh)
    end
end