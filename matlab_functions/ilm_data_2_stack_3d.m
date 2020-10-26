% Convert from data to stack format
function[stack] = ilm_data_2_stack_3d(data)
    n_data = length(data);
    [ny, nx] = size(data(1).image);
    
    stack = zeros(ny, nx, n_data, class(data(1).image));
    for ik=1:n_data
        stack(:, :, ik) = data(ik).image;
    end
end