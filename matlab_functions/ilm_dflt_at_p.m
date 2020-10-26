function[at_p] = ilm_dflt_at_p(n_data)
    at_p = zeros(n_data, 6);
    at_p(:, 1) = 1;
    at_p(:, 4) = 1;
end