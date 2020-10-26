function[mfcube]=ilm_mfft3d_for_fitting(cube, n, f_bw, g_max)    
    if(nargin<3)
        f_bw = repmat(0.95, 1, 3);
    end
    
    if(nargin<2)
        n = 0.5;
    end

    if(numel(f_bw)<3)
        f_bw = repmat(f_bw(1), 1, 3);
    end
    
    [ny, nx, nz] = ilm_size_data(cube);
    
    if(nargin<4)
       g_max = min([nx, ny, nz]/2-1);
    end
    
    if(nx>nz)
        radius_g_ept = g_max*[1, 1, nz/nx];
    else
        radius_g_ept = g_max*[nx/nz, nx/nz, 1];
    end
    
    fxyz_bw = ilm_func_butterworth_3d(nx, ny, nz, f_bw);
    cube = (cube-mean(cube(:))).*fxyz_bw;
    clear fxyz_bw;
    
    mfcube = abs(fftn(cube)).^n;
    mfcube = ifftshift(mfcube);

    mfcube = mfcube - min(mfcube(:));
    mfcube = mfcube/max(mfcube(:));
    
    d = 6;
    p_c = [nx, ny, nz]/2+1;
    p_0 = p_c-d;
    p_e = p_c+d;
    
    mfcube_0 = mfcube(p_0(2):p_e(2), p_0(1):p_e(1), p_0(3):p_e(3));
    mfcube(p_0(2):p_e(2), p_0(1):p_e(1), p_0(3):p_e(3)) = 0;
    level_min = mean(mfcube(:));
    level_max = max(mfcube(:));
    level_med = graythresh(mfcube((level_min<mfcube)&(mfcube<level_max)));
    level_max = 0.5*(level_med + level_max);
    mfcube(p_0(2):p_e(2), p_0(1):p_e(1), p_0(3):p_e(3)) = mfcube_0;
    mfcube = max(level_min, min(level_max, mfcube));
    mfcube = mfcube - level_min;
    mfcube = mfcube/max(mfcube(:));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    reset(gpuDevice(1));
    sigma = 1.0;
%     mfcube = imgaussfilt3(gpuArray(mfcube), sigma, 'FilterSize', 2*ceil(3.0*sigma)+1 );
%     mfcube = gather(mfcube);
    
    mfcube = imgaussfilt3(mfcube, sigma, 'FilterSize', 2*ceil(3.0*sigma)+1 );
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    se = strel('disk', 15);
    for iz=1:nz
        im_ik = squeeze(mfcube(:, :, iz));
        mfcube(:, :, iz) = imtophat(im_ik, se);
    end
    
    for iy=1:ny
        im_ik = squeeze(mfcube(iy, :, :));
        mfcube(iy, :, :) = imtophat(im_ik, se);
    end
    
    for ix=1:nx
        im_ik = squeeze(mfcube(:, ix, :));
        mfcube(:, ix, :) = imtophat(im_ik, se);
    end
    
    mask_g_ept = ilm_ellipsoid_butterworth(nx, ny, nz, radius_g_ept, 32);
    mfcube = mfcube.*mask_g_ept;
    
    mfcube = mfcube - min(mfcube(:));
    mfcube = mfcube/max(mfcube(:));
end