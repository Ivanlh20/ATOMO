function[] = ilm_plot_circle_wc(x_c, y_c, radius, str_lc, str_cc)
    if(nargin<5)
        str_cc = '+b';
    end
    
    if(nargin<4)
        str_lc = '-r';
    end
    
    d_theta = pi/50;
    t_h = 0:d_theta:(2*pi + 0.1);
    x_l = radius*cos(t_h) + x_c;
    y_l = radius*sin(t_h) + y_c; 
    plot(x_l, y_l, str_lc, x_c, y_c, str_cc);
end