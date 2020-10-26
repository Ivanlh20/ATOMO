% p = [x_min, y_min; z_min; x_max, y_max, z_max]
function[atoms] = ilm_select_atoms_out_box(atoms, p)
    n_col = min(3, size(p, 2));
    
    x = atoms(:, 2);
    bb = (p(1, 1)<=x)&(x<=p(2, 1)); 
    
    if(n_col>=2)
        y = atoms(:, 3);    
        bb = bb&(p(1, 2)<=y)&(y<=p(2, 2));
    end
    
    if(n_col>=3)
        z = atoms(:, 4); 
        bb = bb&(p(1, 3)<=z)&(z<=p(2, 3)); 
    end
	
    atoms = atoms(~bb, :);
end