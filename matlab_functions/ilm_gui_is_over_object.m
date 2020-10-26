function [bb] = ilm_gui_is_over_object(src, obj)
    % get figure position, [x y width height]
    pos_fg = get(src, 'Position');

    % get the current position of the mouse
    pos_m = get(src, 'CurrentPoint');
    m_x = pos_m(1);
    m_y = pos_m(2);  

    % get the position and dimensions of the object
    n_obj = length(obj);
    bb = zeros(n_obj, 1);
    for ik=1:n_obj
        ax_pos = get(obj(ik), 'Position');

        ax_x0 = ax_pos(1)*pos_fg(3);
        ax_xe = (ax_pos(1)+ax_pos(3))*pos_fg(3);
        
        ax_y0 = ax_pos(2)*pos_fg(4);
        ax_ye = (ax_pos(2)+ax_pos(4))*pos_fg(4); 

        bb(ik) = (ax_x0<=m_x)&&(m_x<=ax_xe)&& (ax_y0<=m_y)&&(m_y<=ax_ye);      
    end
end