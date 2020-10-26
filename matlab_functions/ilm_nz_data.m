function[nz] = ilm_nz_data(data)
    if(isstruct(data))
        nz = numel(data);
    else
        nz = size(data, 3);
    end
end