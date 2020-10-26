% Read atomic positions from lammps file
function [atoms, lx, ly, lz] = ilm_read_ap_lammps(Z, path)
    fileID = fopen(path, 'r');
    fgetl(fileID);
    fgetl(fileID);
    str = textscan(deblank(fgetl(fileID)) , '%f %s');
    natoms = str{1};
    fgetl(fileID);
    
    str = textscan(deblank(fgetl(fileID)) , '%f %f %s');
    lx = str{2}-str{1};
    str = textscan(deblank(fgetl(fileID)) , '%f %f %s');
    ly = str{2}-str{1};
    str = textscan(deblank(fgetl(fileID)) , '%f %f %s');
    lz = str{2}-str{1};  
    
    while ~feof(fileID)
        str = fgetl(fileID);
        str = strtrim(str);
        if strcmpi(str, 'Atoms')
            fgetl(fileID);
            break;
        end
    end
    
    t = textscan(fileID, '%d%d%f%f%f', natoms, 'Delimiter', '\t', 'MultipleDelimsAsOne', 1);
    fclose(fileID);
    
    I = ones(natoms, 1);
    atoms = [Z(t{2}), t{3}, t{4}, t{5}, 0.085*I, 1.0*I];    
end