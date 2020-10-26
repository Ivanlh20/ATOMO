function[cube]=ilm_adapthisteq_3d(cube, N, NumTiles)   
    if(nargin<2)
        N = 2^16;
    end
    
    if(nargin<3)
        NumTiles = [10, 10];
    end

    ClipLimit = 1/N;
    [ny, nx, nz] = size(cube);
    cube = cube/max(cube(:));
    se = strel('disk', 6);
    
    for iz=1:nz
        im_ik = squeeze(cube(:, :, iz));
        f = max(im_ik(:));
        if(f<1e-10)
            continue;
        end
        im_ik = im_ik/f;
        im_ik = imtophat(im_ik, se);
        im_ik = im_ik/max(im_ik(:));
        im_ik = adapthisteq(im_ik, 'NumTiles', NumTiles, 'ClipLimit', ClipLimit, 'NBins', N, 'Distribution', 'uniform');
        im_ik = im_ik*f;
        cube(:, :, iz) = im_ik;
    end
    disp('33%')
    
    for iy=1:ny
        im_ik = squeeze(cube(iy, :, :));
        f = max(im_ik(:));
        if(f<1e-10)
            continue;
        end
        im_ik = im_ik/f;
        im_ik = imtophat(im_ik, se);
        im_ik = im_ik/max(im_ik(:));
        im_ik = adapthisteq(im_ik, 'NumTiles', NumTiles, 'ClipLimit', ClipLimit, 'NBins', N, 'Distribution', 'uniform');
        im_ik = im_ik*f;
        cube(iy, :, :) = im_ik;
    end
    disp('66%')
    
    for ix=1:nx
        im_ik = squeeze(cube(:, ix, :));
        f = max(im_ik(:));
        if(f<1e-10)
            continue;
        end
        im_ik = im_ik/f;
        im_ik = imtophat(im_ik, se);
        im_ik = im_ik/max(im_ik(:));
        im_ik = adapthisteq(im_ik, 'NumTiles', NumTiles, 'ClipLimit', ClipLimit, 'NBins', N, 'Distribution', 'uniform');
        im_ik = im_ik*f;
        cube(:, ix, :) = im_ik;
    end
    disp('100%')
end