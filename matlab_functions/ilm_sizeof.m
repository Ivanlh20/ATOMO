function [size_bytes] = ilm_sizeof(dtype)
    size_bytes = 0;
    try
        z = zeros(1, dtype);
        w = whos('z');
        size_bytes = w.bytes;
    catch
        error('Unsupported class for finding size');
    end
end