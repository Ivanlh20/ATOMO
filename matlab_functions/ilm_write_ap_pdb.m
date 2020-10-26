% Write atomic positions to pdb file
function [] = ilm_write_ap_pdb(path, atoms, a, b, c, alpha, beta, gamma)
    if(nargin<8)
        gamma = 90;
    end
    
    if(nargin<7)
        beta = 90;
    end
    
    if(nargin<6)
        alpha = 90;
    end   
    
    if(nargin<5)
        c = max(atoms(:, 4)) - min(atoms(:, 4));
    end
    
    if(nargin<4)
       b = max(atoms(:, 3)) - min(atoms(:, 3));
    end
    
    if(nargin<3)
       a = max(atoms(:, 2)) - min(atoms(:, 2));
    end  
    
    ces = {' H', 'He', 'Li', 'Be', ' B', ' C', ' N', ' O', ' F', 'Ne', 'Na', 'Mg', 'Al', 'Si', ' P', ' S', 'Cl', 'Ar', ' K', 'Ca', ...
    'Sc', 'Ti', ' V', 'Cr', 'Mn', 'Fe', 'Co', 'Ni', 'Cu', 'Zn', 'Ga', 'Ge', 'As', 'Se', 'Br', 'Kr', 'Rb', 'Sr', ' Y', 'Zr', ...
    'Nb', 'Mo', 'Tc', 'Ru', 'Rh', 'Pd', 'Ag', 'Cd', 'In', 'Sn', 'Sb', 'Te', ' I', 'Xe', 'Cs', 'Ba', 'La', 'Ce', 'Pr', 'Nd',...
    'Pm', 'Sm', 'Eu', 'Gd', 'Tb', 'Dy', 'Ho', 'Er', 'Tm', 'Yb', 'Lu', 'Hf', 'Ta', ' W', 'Re', 'Os', 'Ir', 'Pt', 'Au', 'Hg',...
    'Tl', 'Pb', 'Bi', 'Po', 'At', 'Rn', 'Fr', 'Ra', 'Ac', 'Th', 'Pa', ' U', 'Np', 'Pu', 'Am', 'Cm', 'Bk', 'Cf'};

    [n_atoms, n_col] = size(atoms);
    idx = 1:n_atoms;
    xyz = atoms(:, 2:4).';
    
    if(n_col>4)
        rmsd = atoms(:, 5).';
    else
        rmsd = 0.085*ones(1, n_atoms);
    end
    
    if(n_col>5)
        occ = atoms(:, 6).';
    else
        occ = ones(1, n_atoms);
    end
    
    C = [num2cell(idx); ces(atoms(:, 1)); num2cell([xyz; rmsd; occ])];
    
    S = sprintf('ATOM%7u %-4s MOL     1    %8.3f%8.3f%8.3f%6.2f%6.2f\n', C{:});
    fileID = fopen(path, 'w');
    fprintf(fileID, 'HEADER mxtal.pdb\n');
    fprintf(fileID, 'TITLE\n');
    fprintf(fileID, 'CRYST1%9.3f%9.3f%9.3f%7.2f%7.2f%7.2f P1\n', a, b, c, alpha, beta, gamma);
    
    fprintf(fileID, S);
    fprintf(fileID, 'END');
    fclose(fileID);
end