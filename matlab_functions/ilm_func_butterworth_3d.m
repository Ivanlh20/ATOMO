function[f_w]=ilm_func_butterworth_3d(nx, ny, nz, fr, type_out)
    if(nargin<5)
        type_out = 'single';
    end
    
    if(numel(fr)==1)
        fr = repmat(fr, 1, 3);
    end
    
    radius_p = round(fr.*[nx, ny, nz]/2);
    
    f_x = ilc_func_butterworth(nx, 1, 1, 1, radius_p(1), 32, 0);
    f_y = ilc_func_butterworth(1, ny, 1, 1, radius_p(2), 32, 0);
    f_z = ilc_func_butterworth(nz, 1, 1, 1, radius_p(3), 32, 0);
    
    f_x = eval([type_out, '(f_x)']);
    f_y = eval([type_out, '(f_y)']);
    f_z = eval([type_out, '(f_z)']);

    f_z = reshape(f_z, 1, 1, nz);
    f_w = f_x.*f_y.*f_z;
end