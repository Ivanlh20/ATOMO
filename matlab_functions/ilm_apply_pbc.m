function[r]=ilm_apply_pbc(r, bs)
    bs = reshape(bs, 1, []);
    if size(r, 2)==2
        r = r - floor(r./bs(1:2)).*bs(1:2); % wrap positions
    elseif size(r, 2)==3
        r = r - floor(r./bs(1:3)).*bs(1:3); % wrap positions
    end
end