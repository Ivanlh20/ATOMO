function[] = ilm_plot_circle(x_c, y_c, radius, color, tag)
    if(nargin<5)
        tag = 'f';
    end
    
    d_theta = pi/50;
    t_h = 0:d_theta:(2*pi + 0.1);
    x_t = radius*cos(t_h) + x_c;
    y_t = radius*sin(t_h) + y_c; 
    lo = line(x_t, y_t, 'LineWidth', 2, 'Color', color); 
    lo.Tag = tag;
end