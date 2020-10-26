% Write atomic positions to lammps file
function [] = ilm_write_ap_lammps(path, atoms, lx, ly, lz, masses)
    if(nargin<6)
        masses = [];
    end
    
    n_atoms = size(atoms, 1);
    iZ = sort(unique(round(atoms(:, 1))));
    natom_type = length(iZ);
    fileID = fopen(path, 'w');
    fprintf(fileID, 'LAMMPS data file for Nanoparticles\n');
    fprintf(fileID, '\n');
    fprintf(fileID, sprintf('%d atoms\n', n_atoms));
    fprintf(fileID, sprintf('%d atom types\n', natom_type));
    fprintf(fileID, sprintf('%8.4f %8.4f xlo xhi\n', 0, lx));
    fprintf(fileID, sprintf('%8.4f %8.4f ylo yhi\n', 0, ly));
    fprintf(fileID, sprintf('%8.4f %8.4f zlo zhi\n', 0, lz));
    
    if(~isempty(masses))
        % https://lammps.sandia.gov/doc/mass.html
        fprintf(fileID, '\n');
        fprintf(fileID, 'Masses\n');
        fprintf(fileID, '\n');
        for ik=1:length(masses)
            fprintf(fileID, [num2str(ik), ' ', num2str(masses(ik), '%11.8f'), '\n']);
        end
    end
    
    fprintf(fileID, '\n');
    fprintf(fileID, 'Atoms\n');
    fprintf(fileID, '\n');

    A = ones(n_atoms, 5);
    A(:, 1) = cumsum(A(:, 1));

    ic = 1;
    for ik=1:length(iZ)
        A(atoms(:, 1)==iZ(ik), 2) = ic;
        ic = ic + 1;
    end

    A(:, 3:5) = atoms(:, 2:4);
    fprintf(fileID, '%d\t%d\t%12.8f\t%12.8f\t%12.8f\n', A'); 
    fclose(fileID);

    % for i = 1:natom
    %  line = sprintf('%d\t%d\t%12.8f\t%12.8f\t%12.8f\n', i, 1, atoms(i, 2), atoms(i, 3), atoms(i, 4));
    %  fprintf(fileID, line); 
    % end
    % fclose(fileID);
end