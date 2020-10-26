% Convert from stack to data format
function[data] = ilm_stack_4d_2_data(stack)
    ny_p = size(stack, 3);
    nx_p = size(stack, 4);  
    
    ic = 1;
    for ix=1:nx_p
        for iy=1:ny_p
            data(ic).image = stack(:, :, iy, ix);
            ic = ic + 1;
        end
    end
end