function[atoms] = ilm_remove_atoms_pbc(atoms, lx, ly, lz, ee)
    if nargin< 2
        ee = 1e-2;
    end
    
    atoms = atoms((atoms(:, 2)<lx-ee)&(atoms(:, 3)<ly-ee)&(atoms(:, 4)<lz-ee), :);
end