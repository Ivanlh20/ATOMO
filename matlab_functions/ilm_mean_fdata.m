function[image_fav] = ilm_mean_fdata(data, fh)
    b_st = isstruct(data);
    [ny, nx, n_data] = ilm_size_data(data);
    dx = 1; 
    dy = 1;

    if(nargin<2)
        fh = ilc_func_hanning(nx, ny, dx, dy, 0.05);
    end
    
    image_fav = complex(zeros(ny, nx));
    for ik = 1:n_data
        image_ik = ilm_extract_data(data, ik, b_st, 'double');
        image_ik = ifftshift(image_ik);
        image_fav = image_fav + fft2(image_ik.*fh);
    end
    image_fav = fftshift(image_fav/n_data);
end