% Convert from data to stack format
function[stack] = ilm_data_2_stack_4d(data)
    [ny_p, nx_p] = size(data);
    [ny, nx] = size(data(1).image);
    
    stack = zeros(ny, nx, ny_p, nx_p, class(data(1).image));
    ic = 1;
    for ix=1:nx_p
        for iy=1:ny_p
            stack(:, :, iy, ix) = data(ic).image;
            ic = ic + 1;
        end
    end
end