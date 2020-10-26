%%% from space group to Bravais lattice
function[bl] = ilm_sg_2_bl(sg)
    if(sg<=2)       % Triclinic
        bl = 1;
    elseif(sg<=15)  % Monoclinic
        bl = 2;
    elseif(sg<=74)  % Orthorhombic
        bl = 3;
    elseif(sg<=142) % Tetragonal
        bl = 4;
    elseif(sg<=167) % Trigonal (rhombohedral or Hexagonal)
        bl = 5;
    elseif(sg<=194) % Hexagonal
        bl = 6;
    else            % Cubic
        bl = 7;
    end
end