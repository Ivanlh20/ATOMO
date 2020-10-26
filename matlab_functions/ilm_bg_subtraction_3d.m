function[cube]=ilm_bg_subtraction_3d(cube, radius)   
    se = strel('disk', radius);
    f_min = 1e-6;
    [ny, nx, nz]  = size(cube);
    
    cube = cube/max(cube(:));
    for iz=1:nz
        im_ik = squeeze(cube(:, :, iz));
        f = max(im_ik(:));
        if(f<f_min)
            continue;
        end
        im_ik = im_ik/f;
        cube(:, :, iz) = imtophat(im_ik, se);
    end
    disp('33%')
    
    cube = cube/max(cube(:));
    for iy=1:ny
        im_ik = squeeze(cube(iy, :, :));
        f = max(im_ik(:));
        if(f<f_min)
            continue;
        end
        im_ik = im_ik/f;
        cube(iy, :, :) = imtophat(im_ik, se);
    end
    disp('66%')
    
    cube = cube/max(cube(:));
    for ix=1:nx
        im_ik = squeeze(cube(:, ix, :));
        f = max(im_ik(:));
        if(f<f_min)
            continue;
        end
        im_ik = im_ik/f;
        cube(:, ix, :) = imtophat(im_ik, se);
    end
    disp('100%')
end