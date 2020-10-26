function[data] = ilm_bd_2_data(data, bd, opt)
    if(nargin<3)
        opt = 1;
    end
    
    n_data = length(data);
    dx = 1;
    dy = 1;
    
    for ik=1:n_data
        data(ik).image = ilc_set_bd(data(ik).image, dx, dy, bd, opt);
    end
end