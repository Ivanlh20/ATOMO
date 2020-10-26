% from crystal system string to space group range
function[sg_0, sg_e]=ilm_crystal_css_2_sgr(str)

    csn = ilm_crystal_css_2_csn(str); % crystal system number
    
    [sg_0, sg_e] = ilm_crystal_csn_2_sgr(csn);
end