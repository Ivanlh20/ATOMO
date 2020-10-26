function[] =ilm_show_proj_crystal(fig, atoms, lx, ly)
    if(nargin<4)
       lx = max(atoms(:, 2));
       ly = max(atoms(:, 3));
    end
    aZ = unique(atoms(:, 1)); 
    figure(fig); clf;
    plot(lx/2, ly/2, 'o', 'MarkerSize', 6, 'MarkerEdgeColor', 'black');
    for iZ=1:length(aZ)
        hold all;
        ii = find(atoms(:, 1)==aZ(iZ));
        plot(atoms(ii, 2), atoms(ii, 3), 'o', 'MarkerSize', 2, 'MarkerFaceColor', 'auto');
    end
    hold on;
    plot([0 0], [0 ly], '-r', [0 lx], [ly ly], '-r', [lx lx], [ly 0], '-r', [lx 0], [0 0], '-r');
    axis equal;
    axis([0, lx+0.1, 0, ly+0.1])
end