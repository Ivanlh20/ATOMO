% from space group number to crystal system number
function[csn]=ilm_crystal_sgn_2_csn(sgn)

    csn = 1;
    if(ilm_chk_bound(sgn, 1, 3))          % triclinic or anorthic
        csn = 1;
    elseif(ilm_chk_bound(sgn, 3, 16))     % monoclinic
        csn = 2;
    elseif(ilm_chk_bound(sgn, 16, 75))    % orthorhombic
        csn = 3;
    elseif(ilm_chk_bound(sgn, 75, 143))   % tetragonal
        csn = 4;
    elseif(ilm_chk_bound(sgn, 143, 168))  % rhombohedral or trigonal
        csn = 5;
    elseif(ilm_chk_bound(sgn, 168, 195))  % hexagonal
        csn = 6;
    elseif(ilm_chk_bound(sgn, 195, 231))  % cubic
        csn = 7;
    end
end