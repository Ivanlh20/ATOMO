function [] = ilm_plot_bd(lx, ly, bd, c)
    if(nargin<4)
        c = '-r';
    end
    hold on;
    xy = ilm_bd_2_xy(lx, ly, bd);
    xy = [xy; xy(1,:)];
    plot(xy(:, 1), xy(:, 2), c, 'LineWidth', 2);
end