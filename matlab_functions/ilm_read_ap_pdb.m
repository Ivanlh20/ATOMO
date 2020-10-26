function [atoms, lx, ly, lz] = ilm_read_ap_pdb(path, rms3d_0)
    if(nargin<2)
        rms3d_0 = 0.085;
    end
    occ = 1.0;  
    
    fid = fopen(path, 'r');
    atoms = []; 
    while feof(fid) == 0
        text = strtrim(upper(sscanf(fgetl(fid), '%c')));
        if (contains(text, 'ATOM ')||contains(text, 'HETATM '))
            C = textscan(text, '%s %u %s %s %u %f %f %f %f %f %s');
            if(ischar(C{3}))
                Z = ilm_Z(C{3});
            else
                Z = ilm_Z(C{4});
            end
            
            x = C{6};
            y = C{7};
            z = C{8};
            if(~isempty(C{9}))
                rms3d = C{9};
                if(~ilm_chk_bound(rms3d, 0, 5))
                    rms3d = rms3d_0;
                end
            else
                rms3d = rms3d_0;
            end
            atoms = [atoms; [Z, x, y, z, rms3d, occ]];
         end
    end
    fclose(fid);
    xyz = atoms(:, 2:4);
    xyz = xyz - min(xyz);
    [lx, ly, lz] = ilm_vect_assign(max(xyz));
    atoms(:, 2:4) = xyz;
end