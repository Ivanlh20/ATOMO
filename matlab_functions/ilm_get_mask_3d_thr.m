function[mask]=ilm_get_mask_3d_thr(cube, f_th, bb_sqrt)
    if(nargin<3)
        bb_sqrt = true;
    end
    
    if(nargin<2)
        f_th = 0.5;
    end
    
    [ny, nx, nz] = size(cube);
    f_sc = max([ny, nx, nz])/256;
    mask = max(0, imresize3(cube, 1/f_sc));
    
    if(bb_sqrt)
        mask = gather(imgaussfilt3(gpuArray(sqrt(mask)), 2.0, 'padding', 'circular'));
    else
        mask = gather(imgaussfilt3(gpuArray(mask), 2.0, 'padding', 'circular'));
    end
    
    mask = mask/max(mask(:));
    level = f_th*graythresh(mask);
    mask = single(mask>level);
    sigma = 1;
    mask = gather(imgaussfilt3(gpuArray(mask), sigma, 'FilterSize', 2*ceil(3.5*sigma)+1, 'padding', 'circular'));
    mask = max(0, imresize3(mask, size(cube)));
    mask = mask/max(mask(:));
end