function[image_av] = ilm_mean_data(data)
    b_st = isstruct(data);
    [ny, nx, n_data] = ilm_size_data(data);
    
    image_av = zeros(ny, nx);
    for ik = 1:n_data
        image_ik = ilm_extract_data(data, ik, b_st, 'double');
        image_av = image_av + image_ik;
    end
    image_av = image_av/n_data;
end