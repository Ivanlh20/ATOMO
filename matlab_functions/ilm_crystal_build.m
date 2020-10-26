function[atoms]=ilm_crystal_build(crystal_par)  
    a = crystal_par.a;
    b = crystal_par.b;
    c = crystal_par.c;
    
    alpha = crystal_par.alpha;
    beta = crystal_par.beta;
    gamma = crystal_par.gamma;
    
    na = crystal_par.na;
    nb = crystal_par.nb;
    nc = crystal_par.nc;
    
    base = crystal_par.base;
    n_base = size(base, 1);
    
    if(crystal_par.pbc)
        na = na - 1;
        nb = nb - 1;
        nc = nc - 1;
    end

    dsm = ilm_crystal_dsm(a, b, c, alpha, beta, gamma);
    
    [iRx, iRy, iRz] = meshgrid(0:na, 0:nb, 0:nc);

    R = [iRx(:), iRy(:), iRz(:)];
    
    atoms = repmat(base, size(R, 1), 1);
    atoms(:, 2:4)= reshape(repmat(R, 1, n_base).', 3, []).' + atoms(:, 2:4);

    if(~crystal_par.pbc)
        ee = 1e-3;
        x_e = na + ee;
        y_e = nb + ee;
        z_e = nc + ee;
        
        bb = (atoms(:, 2)<x_e)&(atoms(:, 3)<y_e)&(atoms(:, 4)<z_e);
        atoms = atoms(bb, :);
    end
    
    atoms(:, 2:4) = atoms(:, 2:4)*dsm;
end