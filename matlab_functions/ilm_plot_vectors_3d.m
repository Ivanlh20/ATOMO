function[] = ilm_plot_vectors_3d(p_0, v, color, tag, lw)
    if(nargin<5)
        lw = 2;
    end
    
    if(nargin<4)
        tag = 'f';
    end
    
    if(nargin<3)
        color = 'r';
    end
    
    x_t = [p_0(1); v(1)];
    y_t = [p_0(2); v(2)];
    z_t = [p_0(3); v(3)];
    hold on;
    lo = line(x_t, y_t, z_t, 'LineWidth', lw, 'Color', color); 
    lo.Tag = tag;
end