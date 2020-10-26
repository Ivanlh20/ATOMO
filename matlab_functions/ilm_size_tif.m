% Read size tif file
function [nx, ny, nz] = ilm_size_tif(fn)
    st = imfinfo(fn);
    nz = size(st, 1);
    nx = st(1).Width;
    ny = st(1).Height;
end