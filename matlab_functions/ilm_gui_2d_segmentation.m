function[im_bgs, sel_bord_idx, psb] = ilm_gui_2d_segmentation(system_conf, im_i, sel_bord_idx, psb)
    global pz nx ny sigma Rx Ry ic_s ui_sl_thr ui_pp_sigma im_sft im_sc
    global im im_b im_c_min im_c_max bb_shift_kpf x_c y_c rect_l

    bb_shift_kpf = true;
    
    if(nargin<4)
        psb = 0;
    end
    
    if(nargin<3)
        sel_bord_idx = 2;
    end

    ic_s = 1;
    fy = 0.60;
    fx = 0.725;
    dm = get(0, 'MonitorPositions');
    dm = dm(1, :);
    w = fx*dm(3);
    h = fy*dm(4);
    x0 = (1-fx)*w/2;
    y0 = (1-fy)*h/2;

    fh = figure(1); clf;
    set(fh, {'Name', 'Visible', 'units', 'position'}, {'Segmentation -- Software created by Ivan Lobato: Ivanlh20@gmail.com', 'on', 'pixels',[x0, y0, x0+w, y0+h]})
    movegui(fh, 'center');

    ui_pn_opt = uipanel('Parent', fh, 'Title', 'Options', 'Units', 'normalized',...
    'FontSize', 12, 'BackgroundColor', 'white', 'Position', [0.2 0.9 0.6 0.1]);
         
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    pn_x_0 = 10; 
    pn_y_1 = 10;
    pn_d = 4; 
    pn_h = 24;
    
    pn_w = [75, 85, 75, 200, 55, 75, 40, 50, 75];
    pn_n = length(pn_w);
    pn_x = pn_x_0*ones(1, pn_n);
    for ik=2:pn_n
        pn_x(ik) = pn_x(ik-1) + pn_d + pn_w(ik-1);
    end 
    
    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton', 'String', 'Reset',...
        'Position', [pn_x(1) pn_y_1 pn_w(1) pn_h], 'Callback', @cb_reset); 
       
    ui_pp_sel_bord = uicontrol('Parent', ui_pn_opt, 'Style', 'popup',...
           'String', {'Vertical', 'Horizontal', 'circular'},...
           'Position', [pn_x(2) pn_y_1 pn_w(2) pn_h], 'Value', sel_bord_idx); 
       
    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton', 'String', 'Del Border',...
        'Position', [pn_x(3) pn_y_1 pn_w(3) pn_h], 'Callback', @cb_del_bord); 
       
     ui_sl_thr = uicontrol('Parent', ui_pn_opt, 'Style', 'slider',...
        'SliderStep', [0.01 0.05], 'Min', 0, 'Max', 1000, 'Value', 0,...
        'Position', [pn_x(4) pn_y_1 pn_w(4) pn_h], 'Callback', @(src, ev)fn_set_sigma_thr_v()); 
    
    ui_pp_sigma = uicontrol('Parent', ui_pn_opt, 'Style', 'popup',...
           'String', {'1', '2', '4', '10', '15', '20', '30', '40', '50', '60', '70'},...
           'Position', [pn_x(5) pn_y_1 pn_w(5) pn_h], 'Value',4, 'Callback', @(src, ev)fn_set_sigma_thr_v()); 
       
    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton', 'String', 'bg subt.',...
        'Position', [pn_x(6) pn_y_1 pn_w(6) pn_h], 'Callback', @(src, ev)fn_bgs); 
       
    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'n_bg', 'Position', [pn_x(7) pn_y_1 pn_w(7) pn_h]);

    ui_edt_n_bg = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '4', 'Position', [pn_x(8) pn_y_1 pn_w(8) pn_h]);

    ui_pb_close = uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton', 'String', 'Exit',...
        'Position', [pn_x(9) pn_y_1 pn_w(9) pn_h], 'Callback', @cb_close);  

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    d_f = 0.010;    
    h_f = 0.85;    
    w_1 = h_f*h/w;
    w_2 = w_1;
    
    x_1 = (1-(w_1+w_2+d_f))/2;  
    x_2 = x_1+w_1+d_f; 
    y_0 = 0.025;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax_f(1) = axes('Position', [x_1 y_0 w_1 h_f], 'Visible', 'off'); 
    ax_f(2) = axes('Position', [x_2 y_0 w_2 h_f], 'Visible', 'off'); 
    
    fn_init()
    
    fh.WindowButtonDownFcn = @cb_mouse_click;
    fh.WindowKeyPressFcn = @cb_press_key;
    fh.WindowKeyReleaseFcn = @cb_release_key;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    uiwait(fh)
    
    function thr_v = fn_sl_v_2_thr_v(thr_v_sb)
        thr_v = im_c_min + (im_c_max-im_c_min)*thr_v_sb/1000;
    end

    function thr_v_sb = fn_thr_v_2_sl_v(thr_v)
        thr_v_sb = round((thr_v - im_c_min)*1000/(im_c_max-im_c_min));
    end

    function im_g = fn_gauss_cv_2d(im, sigma)
        f = 384/min(nx, ny);
        im_g = sqrt(max(0, imresize(im, f)));
%         im_g = max(0, imresize(im, f));
        sigma_sr = sigma*f;
        im_g = gather(mat2gray(imgaussfilt(gpuArray(im_g), sigma_sr, 'FilterSize', 2*ceil(5*sigma_sr)+1, 'Padding', 'symmetric')));
        im_g = ilm_min_max_ni(im_g);
        im_g = max(0, imresize(im_g, [ny, nx]));
        
%         im_gt = ilc_gauss_cv_2d(system_conf, im, 1, 1, sigma);
    end

    function [im_b, thr_v] = fn_get_thr_v_im_b(im, sigma)
        im_gt = fn_gauss_cv_2d(im, sigma);
        thr_v = 0.35*ilc_otsu_thr(im_gt, 512);
        im_b = im_gt>thr_v;
    end

    function fn_set_sigma_thr_v(bb_draw)
        if(nargin<1)
            bb_draw = true;
        end

        sigma = str2double(ui_pp_sigma.String{ui_pp_sigma.Value});
        im_gt = fn_gauss_cv_2d(im, sigma);
        
        thr_v = fn_sl_v_2_thr_v(ui_sl_thr.Value);
        im_b = im_gt>thr_v;
        
        if(bb_draw)
            fn_draw_data_ax_2();
        end
    end

    function fn_set_thr_af_bgs()
        sigma = str2double(ui_pp_sigma.String{ui_pp_sigma.Value});
        im_gt = fn_gauss_cv_2d(im, sigma);
        
        np_thr_r = sum(im_b(:));
        thr = ui_sl_thr.Value;
        thr_v = fn_sl_v_2_thr_v(thr);
        
        thr_0 = 1;
        thr_e = 1000;
        while (abs(thr_e-thr_0)>1)
            
            np_thr = sum(im_gt(:)>thr_v);
            
            if(np_thr_r<np_thr)
                thr_0 = thr;
            else
                thr_e = thr;  
            end

            thr = round((thr_0+thr_e)/2);
            thr_v = fn_sl_v_2_thr_v(thr);
        end
        
        ui_sl_thr.Value = thr;
        thr_v = fn_sl_v_2_thr_v(ui_sl_thr.Value);
        im_b = im_gt>thr_v;
        
        fn_draw_data_ax_2();
    end

    function fn_init()
        [ny, nx] = size(im_i);
        
        x_c = nx/2 + 1;
        y_c = ny/2 + 1;
        
        rect_l = ilc_pn_fact(2*round(min(nx, ny)/2));

        [im, im_sft, im_sc] = ilm_min_max_ni(double(im_i));

        im_c_min = 0;
        im_c_max = 1;

        ui_pp_sel_bord.Value = sel_bord_idx;

        pz = [1 ny;... 
            1 nx;... 
            sqrt(ny^2+nx^2) max(ny, nx)/2;... 
            y_c x_c;... 
            ny nx];
        
        pz(3, 2) = mean(pz(3, :));
        
        if(numel(psb)<2)
            if(sel_bord_idx==1)
                psb = [1, ny];
            elseif(sel_bord_idx==2)
                psb = [1, nx];
            end
        end
        
        if(sel_bord_idx<3)
            pz(sel_bord_idx, :) = psb;
        end  
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [Rx, Ry] = meshgrid(1:nx, 1:ny);

        sigma = str2double(ui_pp_sigma.String{ui_pp_sigma.Value});
        
        [im_b, thr_v] = fn_get_thr_v_im_b(im, sigma);
        ui_sl_thr.Value = fn_thr_v_2_sl_v(thr_v);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fn_draw_data_ax_1();
        
        fn_draw_data_ax_2();
    end

    function cb_reset(source, event)
        fn_init();
    end

    % background subtraction
    function fn_bgs()
        ui_pb_close.Enable = 'off';
        
        n_bg = str2double(ui_edt_n_bg.String);
        
        p_rect = fn_length_2_p_rect(rect_l);
        ii_sq = (Rx>=p_rect(1, 1))&(Rx<=p_rect(2, 1))&(Ry>=p_rect(1, 2))&(Ry<=p_rect(2, 2));
        ii_sq = ii_sq(:);
        idx_s = im_b(:) & ii_sq;        
        idx_c = ~im_b(:) & ii_sq;  
        xy_c = [Rx(idx_c), Ry(idx_c)];
        x_s = Rx(idx_s);
        y_s = Ry(idx_s);
        
        for it=1:n_bg
            im_s = im(idx_c);
            im_n_max = max(im_s(:));
            im_s = im_s/im_n_max;

            bg_par = fit(xy_c, im_s, 'poly11'); 
            p00 = bg_par.p00*im_n_max;
            p10 = bg_par.p10*im_n_max;
            p01 = bg_par.p01*im_n_max;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
            bg_s = p00 + p10*x_s + p01*y_s;
            bg_shift = min(0, min(im(idx_s)-bg_s));
%             bg_shift = max(0, min(im(idx_s)-bg_s));
            
            im_s = p00 + p10*Rx + p01*Ry + bg_shift;

            im_mean_b = mean(im(idx_s));
            im = max(0, im - im_s);

            %%%%%%%%%%%%%%%% we keep the mean value constant %%%%%%%%%%%%%%%%%%
            im = im - mean(im(idx_s)) + im_mean_b;
            im = max(0, im);
        end
        
        fn_set_thr_af_bgs();
        
        ui_pb_close.Enable = 'on';
    end

    function cb_close(source, event)
        im_bgs = im_sc.*im + im_sft;
        im_bgs = im_bgs - min(im_bgs(im_b(:)));
        
        im_b = gather(imgaussfilt(gpuArray(single(im_b)), 0.5, 'Padding', 'symmetric'));
        im_bgs = max(0, im_bgs.*double(im_b));
        
        sel_bord_idx = ui_pp_sel_bord.Value;
        psb = pz(sel_bord_idx, :);

        delete(fh)
    end

    function fn_draw_data_ax_1()
        axes(ax_f(1));
        imagesc(im_i);
        axis image off;
        colormap jet; 
        fn_draw_points_ax_1(pz);
    end

    function fn_draw_data_ax_2()
        %%%%%%%%%%%%%%%%%%%%% mimic alpha data %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % imagesc(im, 'AlphaData', max(0.825, im_b));
        im_ch = ilm_add_alpha_channel(im, im_b, 0.75);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        axes(ax_f(2));
        imagesc(im_ch, [0, 1]);
        axis image off;
        colormap jet;
        fg = im(im_b);
        title(['mean = ', num2str(mean(fg), '%5.2f'), ' -  std = ', num2str(std(fg), '%5.2f')])
        fn_plot_rect_ax_f_2(rect_l, 'f');
    end

    function cb_del_bord(source, event)
        ii_s = (Ry<pz(1, 1))|(Ry>pz(1, 2))|(Rx<pz(2, 1))|(Rx>pz(2, 2));
        ii_s = ii_s |((Ry-pz(4,1)).^2 + (Rx-pz(4,2)).^2>pz(3,1)^2);
        ii_s = reshape(ii_s, [], 1);
        im(ii_s) = 0;
        im = max(0, im - min(im(~ii_s)));
        
        sigma = str2double(ui_pp_sigma.String{ui_pp_sigma.Value});
        
        [im_b, thr_v] = fn_get_thr_v_im_b(im, sigma);
        ui_sl_thr.Value = fn_thr_v_2_sl_v(thr_v);
        
        fn_draw_data_ax_2();
    end

    function[p] = fn_set_point(sl_bord, p, pn)
        if(sl_bord==1)
            [~, idx] = min(abs(p(1, :)-pn(1,2)));
            if((p(1, 1)==1)&&(p(1, 2)~=p(5, 1)))
                p(1, 1) = pn(1,2);
            elseif((p(1, 1)~=1)&&(p(1, 2)==p(5, 1)))
                p(1, 2) = pn(1,2);
            else
                p(1, idx) = pn(1,2);
            end
        elseif(sl_bord==2)
            [~, idx] = min(abs(p(2, :)-pn(1,1)));
            if((p(2, 1)==1)&&(p(2, 2)~=p(5, 2)))
                p(2, 1) = pn(1,1);
            elseif((p(2, 1)~=1)&&(p(2, 2)==p(5, 2)))
                p(2, 2) = pn(1,1);
            else
                p(2, idx) = pn(1,1);
            end 
        else                
            p(3, 1) = sqrt((C(1,1)-p(4, 1))^2+(C(1,2)-p(4, 2))^2);
        end
    end
    
    function fn_draw_points_ax_1(p)
        axes(ax_f(1));
        
        line([1, p(5, 2)], [p(1, 1) p(1, 1)], 'LineWidth', 2, 'Color', 'white');
        line([1, p(5, 2)], [p(1, 2) p(1, 2)], 'LineWidth', 2, 'Color', 'white');
        line([p(2, 1) p(2, 1)], [1, p(5, 1)], 'LineWidth', 2, 'Color', 'white');
        line([p(2, 2) p(2, 2)], [1, p(5, 1)], 'LineWidth', 2, 'Color', 'white');

        if(p(3, 1)<p(3, 2))
            th = 0:pi/50:2*pi;
            x = p(3, 1)*cos(th) + p(4, 1);
            y = p(3, 1)*sin(th) + p(4, 2);
            ii = find((x>=1)&(x<p(5, 2))&(y>=1)&(y<p(5, 1)));
            x = x(ii);
            y = y(ii);

            line(x, y, 'LineWidth', 2, 'Color', 'white'); 
        end
    end

    function p_rect = fn_length_2_p_rect(l)
        l = min([nx, ny, ilc_pn_fact(l)]);
        lh = l/2;
        p_rect = [x_c-lh, y_c-lh; x_c+lh-1, y_c+lh-1];
    end

    function fn_plot_rect_ax_f_2(rect_l, tag)
        children = get(ax_f(2), 'Children');
        
        delete(findobj(children, 'Type', 'Line'));
        color = 'white';

        % plot selected rectangle
        axes(ax_f(2));
        p_rect = fn_length_2_p_rect(rect_l);
        ilm_plot_rectangle(p_rect, color, tag);
    end

    function cb_mouse_click(source, event)
        b_ax_f_1 = ilm_gui_is_over_object(source, ax_f(1));
        b_ax_f_2 = ilm_gui_is_over_object(source, ax_f(2));
        
        if(b_ax_f_1)
            ax = ax_f(1);

            children = get(ax, 'Children');
            delete(findobj(children, 'Type', 'Line'));

            C = get(ax, 'CurrentPoint');
            pz = fn_set_point(ui_pp_sel_bord.Value, pz, C);

            fn_draw_points_ax_1(pz);
        elseif(b_ax_f_2)
            C = get(ax_f(2), 'CurrentPoint');
            rect_l = 2*round(max(abs(C(1,1:2)-[x_c, y_c])));
            fn_plot_rect_ax_f_2(rect_l, 'f');
        end

    end

    function cb_press_key(source, event)
        sel_bord_idx = ui_pp_sel_bord.Value;
        if(strcmpi(event.Modifier, 'shift') && bb_shift_kpf)
           ui_pp_sel_bord.Value = ilm_ifelse(sel_bord_idx==1, 2, 1); 
        end
        bb_shift_kpf = false;
    end

    function cb_release_key(source, event)
        ui_pp_sel_bord.Value = sel_bord_idx;
        bb_shift_kpf = true;
    end
end