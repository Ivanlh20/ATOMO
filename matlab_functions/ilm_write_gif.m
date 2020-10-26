% Create a gif file from a 3d array or a data structure
function[] = ilm_write_gif(fn, data, time, tr_opt, map)
    N = 256;
    
    if(nargin<5)
        map = gray(N);
    else
        N = size(map, 1);
    end
    
    if(nargin<4)
        tr_opt = true;
    end
    
    if(nargin<3)
        time = 0.1;
    end
    
    b_s = isstruct(data);
    n_data = ilm_nz_data(data);

    for it=1:n_data
        if(b_s)
            im = data(it).image;
        else
            im = data(:, :, it);
        end

        if(tr_opt)
            im = mat2gray(im);
        end
        
        im = uint8((N-1)*im);

%         rgb = ind2rgb(im, map);
%         [A, map] = rgb2ind(rgb, 255);
%         gray2ind
        if it == 1
            imwrite(im, map, fn, 'gif', 'Loopcount', inf, 'DelayTime', time);
        else
            imwrite(im, map, fn, 'gif', 'WriteMode', 'append', 'DelayTime', time);
        end
    end
end