% from crystal system string to crystal system number
function[csn]=ilm_crystal_css_2_csn(str)
    if(isnumeric(str))
        csn = ilm_set_bound(str, 1, 7);
    else
        str = lower(strtrim(str));
        
        if(strcmp(str, 'triclinic') || strcmp(str, 'a'))        % triclinic or anorthic
            csn = 1;
        elseif(strcmp(str, 'monoclinic') || strcmp(str, 'm'))   % monoclinic
            csn = 2;
        elseif(strcmp(str, 'orthorhombic') || strcmp(str, 'o')) % orthorhombic
            csn = 3;
        elseif(strcmp(str, 'tetragonal') || strcmp(str, 't'))   % tetragonal
            csn = 4;
        elseif(strcmp(str, 'rhombohedral') || strcmp(str, 'r')) % rhombohedral or trigonal
            csn = 5;
        elseif(strcmp(str, 'hexagonal') || strcmp(str, 'h'))    % hexagonal
            csn = 6;
        elseif(strcmp(str, 'cubic') || strcmp(str, 'c'))        % cubic
            csn = 7;
        else
            csn = 1;
        end
    end
end