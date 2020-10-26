% Read data cube tif/mat file
function [cube] = ilm_read_tif_mat(fn, type_out, vn)
    if(nargin<3)
        vn = 'cube';
    end
    
    [~, ~, ext] = fileparts(fn);

    if(strcmpi(ext, '.tif'))
        cube = ilm_read_tif(fn, type_out);
    else
        a_var = whos('-file', fn);
        n_a_var = numel(a_var);
        idx = find(strcmp({a_var.name}, vn), 1, 'first');

        if((n_a_var==1)||(isempty(idx)))
            idx = 1;
        end
        
        load(fn, a_var(idx).name);
        cube = eval([type_out, '(', a_var(idx).name,')']);
    end
end