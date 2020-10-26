function[] =ilm_show_crystal(fig, atoms, bb_clf, bb_rz)
    if(nargin<4)
        bb_rz = true;
    end
    
    if(nargin<3)
        bb_clf = true;
    end
    
    aZ = unique(atoms(:, 1)); 
    figure(fig); 
    
    if(bb_clf)
        clf;
    else
        hold on;
    end
    
    str = {};
    for iZ=1:length(aZ)
        hold all;
        ii = find(atoms(:, 1)==aZ(iZ));
        plot3(atoms(ii, 2), atoms(ii, 3), atoms(ii, 4), 'o', 'MarkerSize', 3, 'MarkerFaceColor', 'auto');
        str{iZ} = num2str(aZ(iZ));
    end
%     legend(str);
    axis equal;
    xlim([min(atoms(:, 2)), max(atoms(:, 2))])
    ylim([min(atoms(:, 3)), max(atoms(:, 3))])
    zlim([min(atoms(:, 4))-2, max(atoms(:, 4))+2])
    view([0 0 1]);
    
    if(bb_rz)
        set(gca, 'zdir', 'reverse');
    end
end