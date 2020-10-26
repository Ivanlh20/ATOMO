function[c_xy] = ilm_image_centroid(im, opt)
    if(nargin<2)
        opt = 1;
    end
    
    if(opt==2)
       im = ilm_min_max_ni(im);
    end
    
    [ny, nx] = size(im);
    [Rx, Ry] = meshgrid(1:nx, 1:ny);
    im = im(:);
    x_c = sum(Rx(:).*im)/sum(im);
    y_c = sum(Ry(:).*im)/sum(im);
    c_xy = [x_c, y_c];
end