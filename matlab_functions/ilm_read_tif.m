% Read tif file
function [data] = ilm_read_tif(filename, type_out)
    n_data = size(imfinfo(filename),1);
    for ik = 1:n_data
      im = imread(filename, ik);
      if(ik==1)
          [ny, nx] = size(im);
          data = zeros(ny, nx, n_data, type_out);
      end
        data(:, :, ik) = im;
    end
end