function[data_o] = ilm_resize_2_data(data, fr, mw)
    n_data = ilm_nz_data(data);
    
    if(nargin<3)
        mw = 1;
    end
    
    if(isstruct(data))
        for ik=1:n_data
            im = double(data(ik).image);
            im = imresize(im, fr).*mw;
            data_o(ik).image = im;
        end
    else
        for ik=1:n_data
            im = double(data(:, :, ik));            
            im = imresize(im, fr).*mw;
            if(ik==1)
                [ny, nx] = size(im);
                data_o = zeros(ny, nx, n_data);
            end
            data_o(:, :, ik) = im;
        end    
    end
end