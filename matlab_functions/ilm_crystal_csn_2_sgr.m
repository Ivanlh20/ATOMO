% from crystal system number to space group range
function[sg_0, sg_e]=ilm_crystal_csn_2_sgr(csn)
    if(csn==1)          % triclinic or anorthic
        sg_0 = 1;
        sg_e = 2;
    elseif(csn==2)      % monoclinic
        sg_0 = 3;
        sg_e = 15;
    elseif(csn==3)      % orthorhombic
        sg_0 = 16;
        sg_e = 74;
    elseif(csn==4)      % tetragonal
        sg_0 = 75;
        sg_e = 142;
    elseif(csn==5)      % rhombohedral or trigonal
        sg_0 = 143;
        sg_e = 167;
    elseif(csn==6)      % hexagonal
        sg_0 = 168;
        sg_e = 194;
    elseif(csn==7)      % cubic
        sg_0 = 195;
        sg_e = 230;
    end
end