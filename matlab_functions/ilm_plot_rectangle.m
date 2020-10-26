function[] = ilm_plot_rectangle(p_rect, color, tag, lw)
    if(nargin<4)
        lw = 2;
    end
    
    if(nargin<3)
        tag = 'f';
    end
    
    if(nargin<2)
        color = 'r';
    end
    
    x_t = [p_rect(1, 1), p_rect(2, 1), p_rect(2, 1), p_rect(1, 1), p_rect(1, 1)];
    y_t = [p_rect(1, 2), p_rect(1, 2), p_rect(2, 2), p_rect(2, 2), p_rect(1, 2)];
    lo = line(x_t, y_t, 'LineWidth', lw, 'Color', color); 
    lo.Tag = tag;
end