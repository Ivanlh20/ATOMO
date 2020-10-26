function[ny, nx, nz] = ilm_size_data(data)
    if(isstruct(data))
        nz = numel(data);
        [ny, nx] = size(data(1).image);
    else
        [ny, nx, nz] = size(data);
    end
end