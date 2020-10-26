% Read atomic positions from dump lammps file
function[xyz, bs] = ilm_read_ap_dump_lammps(path, ncols, iconf_0)
    if nargin<3
        iconf_0 = 0;
    end
    
    [n_atoms, n_conf, bs] = fcn_n_atoms_conf_bs(path);
    
    sextract = strtrim(repmat('%f ', 1, ncols));

    if iconf_0 == 0
        xyz = zeros(n_atoms, 3, n_conf);
        
        fileID = fopen(path, 'r');
        ic = 1;
        while ~feof(fileID) && (ic<=n_conf)
            xyz(:, :, ic) = fcn_read_pos(fileID, sextract, n_atoms);
            ic = ic + 1;
        end
        fclose(fileID);
    else
        xyz = zeros(n_atoms, 3);
        
        fileID = fopen(path, 'r');
        ic = 1;
        while ~feof(fileID) && (ic<=iconf_0)
            atoms_conf = fcn_read_pos(fileID, sextract, n_atoms);
            if(ic==iconf_0)
                xyz = atoms_conf;
                break;
            end
            ic = ic + 1;
        end
        fclose(fileID);
    end
end

function [n_atoms, n_conf, bs] = fcn_n_atoms_conf_bs(path)
    fid = fopen(path, 'r');
    g = textscan(fid,'%s','delimiter','\n');
    fclose(fid);
    n_atoms = str2double(char(g{1}(4)));
    n_lines = length(g{1});
    n_conf = round(n_lines/(9+n_atoms));
    
    str = textscan(deblank(char(g{1}(6))) , '%f %f %s');
    bs(1) = str{2}-str{1};
    str = textscan(deblank(char(g{1}(7))) , '%f %f %s');
    bs(2) = str{2}-str{1};
    str = textscan(deblank(char(g{1}(8))) , '%f %f %s');
    bs(3) = str{2}-str{1};  
end

function[atoms_t] = fcn_read_pos(fileID, sextract, natoms)
    for i2 =1:9
        fgetl(fileID);
    end
    t = textscan(fileID, sextract, 'Delimiter', '\t', 'MultipleDelimsAsOne', natoms);
    atoms_t = [t{1}, t{2}, t{3}];
end