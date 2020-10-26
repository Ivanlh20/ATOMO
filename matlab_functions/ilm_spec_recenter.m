function [atoms, sft] = ilm_spec_recenter(atoms, lx, ly, lz, opt)
    if(nargin<3)
        ly = lx;
    end
    
    if(nargin==3)
        lz = lx;
    end    
    
    if(nargin==3)
        opt = 2;
    elseif(nargin<5)
        opt = 1;
    end
    
    xyz_min = min(atoms(:, 2:4));
    atoms(:, 2:4) = atoms(:, 2:4)- xyz_min;
    xys_m = 0.5*([lx, ly, lz]-max(atoms(:, 2:4)));
    if(opt==1)
        atoms(:, 2:4) = atoms(:, 2:4) + xys_m;
        if(nargout==2)
            sft = -xyz_min + xys_m;
        end
    else
        atoms(:, 2:3) = atoms(:, 2:3) + xys_m(1:2);
        if(nargout==2)
            sft = -xyz_min(1:2) + xys_m(1:2);
        end
    end  
end