function[x] = ilm_set_bound(x, x_min, x_max)
    x = max(min(x, x_max), x_min);
end