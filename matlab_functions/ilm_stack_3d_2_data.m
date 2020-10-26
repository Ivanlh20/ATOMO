% Convert from stack to data format
function[data] = ilm_stack_3d_2_data(stack)
    n_data = size(stack, 3);
    
    for ik=1:n_data
        data(ik).image = stack(:, :, ik);
    end
end