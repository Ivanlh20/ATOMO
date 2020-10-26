% Read tif or mrc file
function[cube] = ilm_read_tif_or_mrc(path_fn, type_out, opt)
    if(nargin<3)
        opt = 1;
    end
    
    if(nargin<2)
        type_out = 'double';
    end
    
    [~, ~, ext] = fileparts(path_fn);
    if(strcmpi(ext, '.tif'))
        cube = ilm_read_tif(path_fn, type_out, opt);    
    else
        cube = ilm_read_mrc(path_fn, type_out, opt);
    end
end