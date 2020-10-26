function[p] = ilm_find_closest_pos(xyz, p)
    [~, ii] = sort(sum((xyz-p).^2, 2));
    p = xyz(ii(1), :);
end 