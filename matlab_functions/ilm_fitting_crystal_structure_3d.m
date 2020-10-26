function [vectors, d_max, xyz] = ilm_fitting_crystal_structure_3d(xyz_i, p_c_i, v_i)
    global par pxy_click v_s_idx bb_rotate
    global bb_shift bb_control bb_mouse_click
    
    bb_shift = false;
    bb_control = false;
    bb_mouse_click = false;
    bb_rotate = false;
    v_s_idx = 1;
    
    if(nargin<2)
        p_c_i = xyz_i(1, :);
    end
    
    if(nargin<3)
        d = sqrt(sum((xyz_i(:, :)-p_c_i).^2, 2));
        [d, ii] = sort(d);
        d_min = mean(d(2:3));
        v_i = [xyz_i(ii(2), :)-p_c_i; 0, d_min, 0; 0, 0, d_min];
    end
    
    fy = 0.60;
    fx = 0.725;
    dm = get(0, 'MonitorPositions');
    dm = dm(1, :);
    w = fx*dm(3);
    h = fy*dm(4);
    x0 = (1-fx)*w/2;
    y0 = (1-fy)*h/2;

    fh = figure(1); clf;
    set(fh, {'Name', 'Visible', 'units', 'position'}, {'Fitting crystal structure 3d -- Software created by Ivan Lobato: Ivanlh20@gmail.com', 'on', 'pixels',[x0, y0, x0+w, y0+h]})
    movegui(fh, 'center');

    ui_pn_opt = uipanel('Parent', fh, 'Title', 'Options', 'Units', 'normalized',...
    'FontSize', 12, 'BackgroundColor', 'white', 'Position', [0.1 0.84 0.85 0.152]);
       
    pn_x_0 = 10; 
    pn_y_1 = 65;
    pn_y_2 = 35;
    pn_y_3 = 5;
    pn_d = 4; 
    pn_h = 24;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    pn_w = [40, 45, 45, 45, 40, 45, 45, 45, 40, 45, 45, 45, 40, 45, 45, 45, 40, 45, 45, 45, 65, 75];
    pn_n = length(pn_w);
    pn_x = pn_x_0*ones(1, pn_n);
    for ik=2:pn_n
        pn_x(ik) = pn_x(ik-1) + pn_d + pn_w(ik-1);
    end    
   
    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'v_a', 'Position', [pn_x(1) pn_y_1 pn_w(1) pn_h],...
    'ForegroundColor', 'r', 'Callback', @(src, ev)fn_show_proj_along_axis(1));

    ui_edt_va_x = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '1.00', 'Position', [pn_x(2) pn_y_1 pn_w(2) pn_h]);
    ui_edt_va_y = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.00', 'Position', [pn_x(3) pn_y_1 pn_w(3) pn_h]);
    ui_edt_va_z = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.00', 'Position', [pn_x(4) pn_y_1 pn_w(4) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'v_b', 'Position', [pn_x(5) pn_y_1 pn_w(5) pn_h],...
    'ForegroundColor', 'b', 'Callback', @(src, ev)fn_show_proj_along_axis(2));

    ui_edt_vb_x = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.00', 'Position', [pn_x(6) pn_y_1 pn_w(6) pn_h]);
    ui_edt_vb_y = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '1.00', 'Position', [pn_x(7) pn_y_1 pn_w(7) pn_h]);
    ui_edt_vb_z = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.00', 'Position', [pn_x(8) pn_y_1 pn_w(8) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'v_c', 'Position', [pn_x(9) pn_y_1 pn_w(9) pn_h],...
    'ForegroundColor', 'g', 'Callback', @(src, ev)fn_show_proj_along_axis(3));

    ui_edt_vc_x = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.00', 'Position', [pn_x(10) pn_y_1 pn_w(10) pn_h]);
    ui_edt_vc_y = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.00', 'Position', [pn_x(11) pn_y_1 pn_w(11) pn_h]);
    ui_edt_vc_z = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '1.00', 'Position', [pn_x(12) pn_y_1 pn_w(12) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'v_n', 'Position', [pn_x(13) pn_y_1 pn_w(13) pn_h]);
    ui_edt_vn_x = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.00', 'Position', [pn_x(14) pn_y_1 pn_w(14) pn_h]);
    ui_edt_vn_y = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '0.00', 'Position', [pn_x(15) pn_y_1 pn_w(15) pn_h]);
    ui_edt_vn_z = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '1.00', 'Position', [pn_x(16) pn_y_1 pn_w(16) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'n_abc', 'Position', [pn_x(17) pn_y_1 pn_w(17) pn_h]);
    ui_edt_n_a = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '1', 'Position', [pn_x(18) pn_y_1 pn_w(18) pn_h], 'Callback', @cb_edt_n_abc);
    ui_edt_n_b = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '1', 'Position', [pn_x(19) pn_y_1 pn_w(19) pn_h], 'Callback', @cb_edt_n_abc);
    ui_edt_n_c = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '1', 'Position', [pn_x(20) pn_y_1 pn_w(20) pn_h], 'Callback', @cb_edt_n_abc);

    ui_chk_symm = uicontrol('Parent', ui_pn_opt, 'Style', 'checkbox',... 
    'String', 'symm.', 'Value', 1, 'Position', [pn_x(21) pn_y_1 pn_w(21) pn_h], 'Callback', @cb_set_symm);

    ui_chk_show_grid = uicontrol('Parent', ui_pn_opt, 'Style', 'checkbox',... 
    'String', 'Show grid', 'Value', 0, 'Position', [pn_x(22) pn_y_1 pn_w(22) pn_h], 'Callback', @(src, ev)cb_show_grid);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    pn_w = [75, 60, 60, 80, 45, 50, 75, 80, 75, 65, 65, 80, 75, 75];
    pn_n = length(pn_w);
    pn_x = pn_x_0*ones(1, pn_n);
    for ik=2:pn_n
        pn_x(ik) = pn_x(ik-1) + pn_d + pn_w(ik-1);
    end 

    ui_chk_set_center = uicontrol('Parent', ui_pn_opt, 'Style', 'checkbox',... 
    'String', 'Set center', 'Value', 0, 'Position', [pn_x(1) pn_y_2 pn_w(1) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'sigma_{xy}', 'Position', [pn_x(2) pn_y_2 pn_w(2) pn_h]);

    ui_edt_sigma = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '5.0', 'Position', [pn_x(3) pn_y_2 pn_w(3) pn_h]);
        
    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'Gauss. proj. ', 'Position', [pn_x(4) pn_y_2 pn_w(4) pn_h],...
    'Callback', @cb_show_gaussian_projection);

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'n_iter', 'Position', [pn_x(5) pn_y_2 pn_w(5) pn_h]);

    ui_edt_n_iter = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '200', 'Position', [pn_x(6) pn_y_2 pn_w(6) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'opt. vectors', 'Position', [pn_x(7) pn_y_2 pn_w(7) pn_h],...
    'Callback', @(src, ev)fn_opt_vectors);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'avg. pos.', 'Position', [pn_x(8) pn_y_2 pn_w(8) pn_h],...
    'Callback', @(src, ev)fn_avg_pos);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'uc uniq. pos.', 'Position', [pn_x(9) pn_y_2 pn_w(9) pn_h],...
    'Callback', @(src, ev)fn_uc_uniq_pos);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'String', 'rem. pos.', 'Position', [pn_x(10) pn_y_2 pn_w(10) pn_h],...
    'Callback', @(src, ev)fn_rem_pos);

    uicontrol('Parent', ui_pn_opt, 'Style', 'text',... 
    'String', 'd_min', 'Position', [pn_x(11) pn_y_2 pn_w(11) pn_h]);

    ui_edt_d_min = uicontrol('Parent', ui_pn_opt, 'Style', 'edit',... 
    'String', '1.0', 'Position', [pn_x(12) pn_y_2 pn_w(12) pn_h]);

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',...
    'String', 'reset', 'Position', [pn_x(13) pn_y_2 pn_w(13) pn_h], 'Callback', @(src, ev)fn_init(xyz_i, p_c_i, v_i)); 

    uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton', 'String', 'Close',...
        'Position', [pn_x(14) pn_y_2 pn_w(14) pn_h], 'Callback', @cb_close);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    pn_w = [1200];
    pn_n = length(pn_w);
    pn_x = pn_x_0*ones(1, pn_n);
    for ik=2:pn_n
        pn_x(ik) = pn_x(ik-1) + pn_d + pn_w(ik-1);
    end 
    
    ui_pb_data_info = uicontrol('Parent', ui_pn_opt, 'Style', 'pushbutton',... 
    'Enable', 'inactive', 'String', ' ', 'Position', [pn_x(1) pn_y_3 pn_w(1) pn_h], 'FontSize', 10, 'FontWeight', 'bold');  

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    d_f = 0.01;    
    h_f = 0.775;    
    w_1 = h_f*h/w;
    w_2 = w_1;
    
    x_1 = (1-(w_1+w_2+d_f))/2;  
    x_2 = x_1+w_1+d_f; 
    y_0 = 0.025;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax_f(1) = axes('Position', [x_1 y_0 w_1 h_f], 'Visible', 'off'); 
    ax_f(2) = axes('Position', [x_2 y_0 w_2 h_f], 'Visible', 'off'); 
    
    fn_init(xyz_i, p_c_i, v_i)
    
    fh.WindowButtonMotionFcn = @cb_mouse_move;
    fh.WindowButtonDownFcn = @cb_mouse_click;
    fh.WindowButtonUpFcn = @cb_mouse_release;
    fh.WindowKeyPressFcn = @cb_press_key;
    fh.WindowKeyReleaseFcn = @cb_release_key;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    uiwait(fh)

    function fn_init(xyz, p_c_i, v_i)
        par.symm = ui_chk_symm.Value;
        par.n_xyz = size(xyz, 1);
        par.xyz = xyz;
        par.p_c = p_c_i;
        par.u_z = [0, 0, 1];
        [d, ii] = sort(sqrt(sum((xyz-par.p_c).^2, 2)));
        par.d_max = d(end);
        par.d_min = mean(d(2:3));
        par.v = v_i;
        par.u_n = par.v(3, :);
        par.u_n = par.u_n/norm(par.u_n);
        par.n_v = fn_read_n_v();
        par.xyz_g = fn_create_xyz_grid(par);
        par = fn_rotate(par);
        par.Rm = par.Rm_r;
        [par.xlim, par.ylim] = fn_get_limits(par);
        par.rect = [par.xlim(1), par.ylim(1); par.xlim(2), par.ylim(2)];
        par.lxy = abs(par.ylim(2)-par.ylim(1));
        par.theta_f = sin((pi/180)*(90/par.lxy));
        
        par.nx = 512;
        par.ny = 512;
        pxy_click = [0, 0];
        ui_edt_sigma.String = num2str(max(2, par.d_min/10), '%4.2f');
        vectors = par.v;
        d_max = 1.05*(par.d_max + sqrt(max(sum(par.v.^2, 2))));
        
        children = get(ax_f(1), 'Children');
        delete(findobj(children, 'Type', 'Line'));   
        fn_plot_ax_f1(par, true);
        fn_show_vector_info();
        
        cb_show_gaussian_projection();
    end

    function cb_edt_n_abc(src, ev)
        par.n_v = fn_read_n_v();
        par.xyz_g = fn_create_xyz_grid(par);
        par = fn_rotate(par);
        cb_show_grid();
    end

    function cb_set_symm(src, ev)
        par.symm = src.Value;
        par.xyz_g = fn_create_xyz_grid(par);
        par = fn_rotate(par);
        cb_show_grid();
    end

    function [vf] = fn_rs_2_fs(vr)
        v_a = vr(1, :);
        v_b = vr(2, :);
        v_c = vr(3, :);

        a = norm(v_a);
        b = norm(v_b);
        c = norm(v_c);
        
        beta = acos(dot(v_c, v_a)/(c*a));
        alpha = acos(dot(v_c, v_b)/(c*b));
        gamma = acos(dot(v_a, v_b)/(a*b));

        g = [a^2, a*b*cos(gamma), a*c*cos(beta)];
        g = [g; a*b*cos(gamma), b^2, b*c*cos(alpha)];
        g = [g; a*c*cos(beta), b*c*cos(alpha), c^2];
        g = inv(g).';

        v_a = [1, 0, 0]*g;
        v_b = [0, 1, 0]*g;
        v_c = [0, 0, 1]*g;
        
        a = norm(v_a);
        b = norm(v_b);
        c = norm(v_c);
        m = min([a, b, c]);
        
        v_a = v_a/m;
        v_b = v_b/m;
        v_c = v_c/m;
        
        vf = [v_a; v_b; v_c];
    end

    function s = fn_str_vector_info(v)
        v_a = v(1, :);
        v_b = v(2, :);
        v_c = v(3, :);

        a = norm(v_a);
        b = norm(v_b);
        c = norm(v_c);
        
        alpha = acos(dot(v_c, v_a)/(c*a));
        beta = acos(dot(v_c, v_b)/(c*b));
        gamma = acos(dot(v_a, v_b)/(a*b));

        f = '%4.2f';
        fn = 180/pi;
        s = ['[a, b, c, alpha, beta, gamma] = [', num2str(a, f), ', ', num2str(b, f), ', ', num2str(c, f), ', '];
        s = [s, num2str(alpha*fn, f), ', ', num2str(beta*fn, f), ', ', num2str(gamma*fn, f), ']'];
    end

    function s = fn_str_par_info(vr)     
        s = ['R. space: ', fn_str_vector_info(vr)];
        vf = fn_rs_2_fs(vr);
        s = [s, ' -  F. space: ', fn_str_vector_info(vf)];
    end

    function [im] = fn_gaussian_projection(xyz, sigma)
        A = 1.0;
        system_conf.precision = 1;                     % eP_Float = 1, eP_double = 2
        system_conf.device = 2;                        % eD_CPU = 1, eD_GPU = 2
        system_conf.cpu_nthread = 1; 
        system_conf.gpu_device  = 0;

        xy = xyz(:, 1:2) - par.rect(1, 1:2);
        data = zeros(size(xy, 1), 4);
        data(:, 1:2) = xy;
        data(:, 3) = A;
        data(:, 4) = sigma;

        %%%%%%%%%%%%%%%%%%%%% 1 %%%%%%%%%%%%%%%%%%%%%%%%
        superposition.ff_sigma = 4.5;
        superposition.nx = par.nx;
        superposition.ny = par.ny;
        superposition.dx = par.lxy/superposition.nx;
        superposition.dy = par.lxy/superposition.ny;
        superposition.data = data;

        im = ilc_spt_gauss_2d(system_conf, superposition);
    end

    function cb_show_gaussian_projection(source, event)
        axes(ax_f(2));
        sigma = str2double(ui_edt_sigma.String);
        im = fn_gaussian_projection(par.xyz_r, sigma);

        imagesc(flipud(im));
        axis image off;
        colormap gray;
        title('Gaussian Projection');
    end

    function fn_show_proj_along_axis(idx)
        v_n = par.v(idx, :);
        v_n = v_n/norm(v_n);
        
        if(par.u_n==v_n)
            return;
        end
        
        children = get(ax_f(1), 'Children');
        delete(findobj(children, 'Type', 'Line', '-not', 'Tag', 'f'));

        par.u_n = v_n;
        par = fn_rotate(par);
        fn_plot_ax_f1(par);
        
        par.Rm = par.Rm_r;
        
        cb_show_gaussian_projection();
    end

    function [n_v] = fn_read_n_v()
        n_a = max(1, min(15, round(str2double(ui_edt_n_a.String))));
        n_b = max(1, min(15, round(str2double(ui_edt_n_b.String))));
        n_c = max(1, min(15, round(str2double(ui_edt_n_c.String))));
        n_v = [n_a, n_b, n_c];
    end

    function fn_show_vector_info()
        v = par.v;
        
        ui_edt_va_x.String = num2str(v(1, 1), '%4.3f');
        ui_edt_va_y.String = num2str(v(1, 2), '%4.3f');
        ui_edt_va_z.String = num2str(v(1, 3), '%4.3f');
        
        ui_edt_vb_x.String = num2str(v(2, 1), '%4.3f');
        ui_edt_vb_y.String = num2str(v(2, 2), '%4.3f');
        ui_edt_vb_z.String = num2str(v(2, 3), '%4.3f');
        
        ui_edt_vc_x.String = num2str(v(3, 1), '%4.3f');
        ui_edt_vc_y.String = num2str(v(3, 2), '%4.3f');
        ui_edt_vc_z.String = num2str(v(3, 3), '%4.3f');
        
        ui_pb_data_info.String = fn_str_par_info(par.v);
    end

    function fn_show_v_n(v_n)
        ui_edt_vn_x.String = num2str(v_n(1), '%4.3f');
        ui_edt_vn_y.String = num2str(v_n(2), '%4.3f');
        ui_edt_vn_z.String = num2str(v_n(3), '%4.3f');
    end

    function[xlim, ylim] = fn_get_limits(par)
        xyz_max = 1.01*sqrt(max(sum((par.xyz - par.p_c).^2, 2)));
        xlim = [-xyz_max, xyz_max] + par.p_c(1);
        ylim = [-xyz_max, xyz_max] + par.p_c(2);
    end

    function [xy] = norm_xy(xy, f)
        xy = xy*f;
    end

    function[u_n] = fn_cal_u_n(Rm, xy)
        u_n = [xy, 1]*(Rm.');
        u_n = u_n/norm(u_n);
    end

    function [par] = fn_rotate(par)
        if(isequal(par.u_z, par.u_n))
            u_r = par.u_z;
            theta = 0;
        else
            u_r = cross(par.u_z, par.u_n);
            theta = acos(dot(par.u_z, par.u_n))*180/pi;
        end
        
        par.theta = theta;
        par.u_r = u_r;
        par.Rm_r = ilm_rot_mat_3d(theta, u_r);
        par.xyz_r = (par.xyz-par.p_c)*par.Rm_r + par.p_c;
        par.xyz_gr = (par.xyz_g-par.p_c)*par.Rm_r + par.p_c;
        
        par.v_r = par.v*par.Rm_r;
    end

    function[xyz_g]=fn_create_xyz_grid(par)
        p_c = par.p_c(1, :);
        
        v = par.v;
        
        n_a = par.n_v(1);
        n_b = par.n_v(2);
        n_c = par.n_v(3);
        
        if(par.symm)
            ax = (-n_a):1:n_a;
            ay = (-n_b):1:n_b;
            az = (-n_c):1:n_c;
            
            xyz_g = zeros((2*n_a+1)*(2*n_b+1)*(2*n_c+1), 3);
        else
            ax = 0:1:n_a;
            ay = 0:1:n_b;
            az = 0:1:n_c;
            
            xyz_g = zeros((n_a+1)*(n_b+1)*(n_c+1), 3);
        end

        idx = 1;
        for ic = az
            for ib = ay
                for ia = ax
                    xyz_g(idx, :) = p_c + [ia,ib, ic]*v;
                    idx = idx + 1;
                end
            end
        end
    end

    function [chi_2]= fn_chi2(x, par)
    	par.v = reshape(x, [3, 3]).';
        xyz_g = fn_create_xyz_grid(par);
        
        radius_2 = par.radius^2;
        chi2_ik_min = 1/radius_2;
        n_xyz_g = size(xyz_g, 1);
        
        chi_2 = 0;
        for ik_t=1:n_xyz_g
            d2 = sum((par.xyz-xyz_g(ik_t, :)).^2, 2);
            ii = find(d2<radius_2);
            n_ii = size(ii, 1);
            if(n_ii>0)
               chi_2 = chi_2 +  sum(d2(ii))/(n_ii*radius_2);
            else
               chi_2 = chi_2 + chi2_ik_min;
            end
        end
        chi_2 = sqrt(chi_2);
    end

    function fn_opt_vectors()
        par.n_iter = max(1, round(str2double(ui_edt_n_iter.String)));
        par.radius = 0.95*sqrt(min(sum(par.v.^2, 2)))/2;
        x_0 = reshape(par.v.', [1, 9]);
        
        options = optimset('PlotFcns', @optimplotfval, 'MaxIter', par.n_iter);
        x = fminsearch(@(x)fn_chi2(x, par), x_0, options);
        
        par.v = reshape(x, [3, 3]).';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        children = get(ax_f(1), 'Children');
        delete(findobj(children, 'Type', 'Line', '-not', 'Tag', 'f'));
        
        par.n_v = fn_read_n_v();
        par.xyz_g = fn_create_xyz_grid(par);
        
        par = fn_rotate(par);
        fn_plot_ax_f1(par);
        par.Rm = par.Rm_r;
        
        cb_show_gaussian_projection();
        
        vectors = par.v;
        d_max = 1.05*(par.d_max + sqrt(max(sum(par.v.^2, 2))));
        
         fn_show_vector_info();
    end

    function fn_avg_pos()
        xy_c = ilc_xy_2_xyc(par.xyz_gr(:, 1:2), 1);
        xy_c = xy_c(:, 1:2);
        radius = ilc_min_dist(xy_c)/2;

        xyz_r = ilc_xy_2_xy_mean(xy_c, radius, par.xyz_r(:, 1:2));
        par.xyz_r(2:end, 1:2) = xyz_r(2:end, :);
        par.xyz = (par.xyz_r-par.p_c)*(par.Rm_r.') + par.p_c;
        
        children = get(ax_f(1), 'Children');
        delete(findobj(children, 'Type', 'Line', '-not', 'Tag', 'f'));
                    
        fn_plot_ax_f1(par);
    end

    function fn_uc_uniq_pos()
        n_xyz_g = size(par.xyz_g, 1);
        if(n_xyz_g~=8)
            return;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%% remove corners %%%%%%%%%%%%%%%%%%%%%%%%%%
        r_min = ilc_min_dist(par.xyz)/2;
        r2_min = r_min^2;
        idx_s = zeros(n_xyz_g-1, 1);
        p_c = par.xyz(1, :);
        ic = 0;
        for it=2:n_xyz_g
            idx = find(sum((par.xyz-par.xyz_g(it, :)).^2, 2)<r2_min);
            if(size(idx, 1)==1)
                ic = ic + 1;
                p_c = p_c + par.xyz(idx, :);
                idx_s(ic) = idx;
            end
        end
        dp_c = mean(par.xyz_g) - p_c/n_xyz_g;
        par.xyz(1, :) = par.xyz_g(1, :) + dp_c;
        par.xyz(idx_s, :) = [];
        par.p_c = par.xyz(1, :);
        
        %%%%%%%%%%%%%%%%%%%%%%%%% reflect points %%%%%%%%%%%%%%%%%%%%%%%%%%
        xyz_n = (par.xyz-par.p_c)/par.v;
        xyz_n = xyz_n - floor(xyz_n);
%         xyz_n = xyz_n - floor(xyz_n);
%         xyz_n = max(0, min(1, xyz_n));
        par.xyz = xyz_n*par.v+par.p_c;
        
        par.xyz_g = fn_create_xyz_grid(par);
        par = fn_rotate(par);
        children = get(ax_f(1), 'Children');
        delete(findobj(children, 'Type', 'Line', '-not', 'Tag', 'f'));
        
        fn_plot_ax_f1(par);
    end

    function fn_rem_pos()
        r_min = str2double(ui_edt_d_min.String);
        r2_min = r_min^2;
        
        %%%%%%%%%%%%%%%%%%%%%%%%% remove points %%%%%%%%%%%%%%%%%%%%%%%%%%
        n_xyz = size(par.xyz, 1);
        idx_s = zeros(n_xyz, 1);
        ic = 0;
        for it=1:n_xyz
            p_c = par.xyz(it, :);
            for it_l=(it+1):n_xyz
                if(sum((par.xyz(it_l, :)-p_c).^2)<r2_min)
                    ic = ic + 1;
                    idx_s(ic) = it_l;
                end
            end
        end
        par.xyz(idx_s(1:ic), :) = [];
        
        par = fn_rotate(par);
        children = get(ax_f(1), 'Children');
        delete(findobj(children, 'Type', 'Line', '-not', 'Tag', 'f'));
        
        fn_plot_ax_f1(par);
    end


    function cb_show_grid()
        children = get(ax_f(1), 'Children');
        delete(findobj(children, 'Type', 'Line', '-not', 'Tag', 'f'));
        fn_plot_ax_f1(par);
    end

    function fn_set_center(idx)
        par.p_c = par.xyz(idx, :);
        [par.xyz(1, :), par.xyz(idx, :)] =  ilm_swap(par.xyz(1, :), par.xyz(idx, :));
        fn_init(par.xyz, par.p_c, par.v)
    end

    function fn_plot_vectors(par)
        p_c = par.p_c(1:2);
        p = repmat(p_c, 1, 1, 3);
        vxy = par.v_r(:, 1:2);
        vr = permute(vxy, [3, 2, 1]).*reshape(par.n_v, 1, 1, 3);
        p_v = cat(1, p, p + vr);
        
        hold on;
        ip = plot(p_v(:, 1, 1), p_v(:, 2, 1), '-r', p_v(:, 1, 2), p_v(:, 2, 2), '-b', p_v(:, 1, 3), p_v(:, 2, 3), '-g', 'LineWidth', 1.25);
        ip(1).Tag = 'm_v';
        ip(2).Tag = 'm_v';
        ip(3).Tag = 'm_v';
        
        a = 2;
        c = {'-r', '-b', '-g'};
        for iv = 1:3
            v_iv = vxy(iv, :);
            u = [v_iv(2), -v_iv(1)];
            mu = norm(u);
            if(mu>0)
                u = a*u/mu;
                for in = 1:par.n_v(iv)
                    p = p_c + [in*v_iv - a*u; in*v_iv + a*u];
                    hold on;
                    ip = plot(p(:, 1), p(:, 2), c{iv}, 'LineWidth', 1.0);
                    ip.Tag = 'm_v';
                end
            end
        end
    end

    function fn_plot_ax_f1(par, bb_rect)
        axes(ax_f(1));
        title('Real space')
        
        if(nargin<2)
            bb_rect = false;
        end
        
        if(bb_rect)
            ilm_plot_rectangle(par.rect, 'b', 'f', 1);
            hold on;
        end
        par.n_v = fn_read_n_v();
        
        ip = plot(par.xyz_r(:, 1), par.xyz_r(:, 2), 'o', 'MarkerSize', 5, 'MarkerEdgeColor', 'c', 'MarkerFaceColor', 'k', 'LineWidth', 0.5);
        ip.Tag = 'm';

        if(ui_chk_show_grid.Value)
            hold on;
            ip = plot(par.xyz_gr(:, 1), par.xyz_gr(:, 2), 'o', 'MarkerSize', 2.5, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r', 'LineWidth', 1.0);
            ip.Tag = 'm';  
        end
        
        hold on;
        ip = plot(par.xyz_r(1, 1), par.xyz_r(1, 2), 'o', 'MarkerSize', 6, 'MarkerEdgeColor', 'c', 'MarkerFaceColor', 'r', 'LineWidth', 1.5);
        ip.Tag = 'm';
        
        fn_plot_vectors(par);
        
        ylim(par.ylim);
        xlim(par.xlim);
        axis off;
        
        fn_show_v_n(par.u_n);
    end

    function cb_close(source, event)
        vectors = par.v;
        d_max = 1.05*(par.d_max + sqrt(max(sum(par.v.^2, 2))));
        xyz = par.xyz;
        delete(fh);        
    end

    function cb_mouse_move(source, event)
        b_ax_f_1 = ilm_gui_is_over_object(source, ax_f(1));
        
        if(b_ax_f_1)
            C = get(ax_f(1), 'CurrentPoint');
            C = C(1,1:2);
            
            if(bb_mouse_click)
                if(ui_chk_set_center.Value)
                    [~, idx] = min(sum((par.xyz_r(:, 1:2)-C).^2, 2));
                    fn_set_center(idx);
                    ui_chk_set_center.Value = 0;
                    return;
                end
                
                if(bb_shift)
                    children = get(ax_f(1), 'Children');
                    delete(findobj(children, 'Type', 'Line', '-and', 'Tag', 'm_v'));
                    
                    v_r = par.v_r(v_s_idx, :);
                    v_r_n = dot(v_r, par.u_z)*par.u_z;
                    v_r_p = [C - par.p_c(1:2), 0];
                    v_r = v_r_n + v_r_p;
                    par.v_r(v_s_idx, :) = v_r;
                    par.v(v_s_idx, :) = v_r*(par.Rm.');
                    par.n_v = fn_read_n_v();
                    par.xyz_g = fn_create_xyz_grid(par);
                    vectors = par.v;
                    d_max = 1.05*(par.d_max + sqrt(max(sum(par.v.^2, 2))));
                     
                    fn_plot_vectors(par);
                    fn_show_vector_info();
                elseif(bb_control)
                    children = get(ax_f(1), 'Children');
                    delete(findobj(children, 'Type', 'Line', '-and', 'Tag', 'm_v'));
                    
                    v_r = par.v_r(v_s_idx, :);
                    v_r_n = dot(v_r, par.u_z)*par.u_z;
                    v_r_p = v_r - v_r_n;
                    v_r = v_r_p;
                    par.v_r(v_s_idx, :) = v_r;
                    par.v(v_s_idx, :) = v_r*(par.Rm.');
                    par.n_v = fn_read_n_v();
                    par.xyz_g = fn_create_xyz_grid(par);
                    vectors = par.v;
                    d_max = 1.05*(par.d_max + sqrt(max(sum(par.v.^2, 2))));
                     
                    fn_plot_vectors(par);
                    fn_show_vector_info();
                else
                    children = get(ax_f(1), 'Children');
                    delete(findobj(children, 'Type', 'Line', '-not', 'Tag', 'f'));

                    n_v = fn_read_n_v();
                    
                    if(~isequal(n_v, par.n_v))
                        par.n_v = n_v;
                        par.xyz_g = fn_create_xyz_grid(par);
                    end
                    
                    xy = C - pxy_click;
                    xy = norm_xy(xy, par.theta_f);
                    par.u_n = fn_cal_u_n(par.Rm, xy);
                    par = fn_rotate(par);
                    
                    fn_plot_ax_f1(par);
                    
                    bb_rotate = true;
                end
            end
        end
    end

    function cb_mouse_click(source, event)
        bb_mouse_click = true;
        
        b_ax_f_1 = ilm_gui_is_over_object(source, ax_f(1));
        if(b_ax_f_1)
            C = get(ax_f(1), 'CurrentPoint');
            pxy_click = C(1, 1:2);
            
            p = pxy_click - par.p_c(1:2);
            [~, v_s_idx] = min(sum((par.v_r(:, 1:2) - p).^2, 2));
        end
    end

    function cb_mouse_release(source, event)
        bb_mouse_click = false;
        
        b_ax_f_1 = ilm_gui_is_over_object(source, ax_f(1));
        if(b_ax_f_1 && ~bb_shift && ~bb_control)
            par.Rm = par.Rm_r;
            
            if(bb_rotate)
                cb_show_gaussian_projection();
                bb_rotate = false;
            end
        end
    end

    function cb_press_key(source, event)
        bb_shift = strcmpi(event.Modifier, 'shift');
        bb_control = strcmpi(event.Modifier, 'control');
    end

    function cb_release_key(source, event)
        bb_shift = false;
        bb_control = false;
    end
end