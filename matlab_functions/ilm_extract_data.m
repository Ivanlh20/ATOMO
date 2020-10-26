function[im_o] = ilm_extract_data(data, ik, b_st, typ_o)
    if(nargin<4)
        typ_o = '';
    end
    
    if(b_st)
        im_o = data(ik).image;
    else
        im_o = data(:, :, ik);
    end
    
    if(~strcmpi(typ_o, ''))
        im_o = eval([typ_o, '(im_o)']);
    end   
end