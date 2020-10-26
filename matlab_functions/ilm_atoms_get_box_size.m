function[Lxyz]=ilm_atoms_get_box_size(atoms)
    xyz = atoms(:, 2:4);
    Lxyz = max(xyz)- min(xyz);
end