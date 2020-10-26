% Read size tif file
function [nx, ny, nz] = ilm_size_tif_mat(fn, vn)
    if(nargin<2)
        vn = 'cube';
    end
    
    [~, ~, ext] = fileparts(fn);

    if(strcmpi(ext, '.tif'))
        [nx, ny, nz] = ilm_size_tif(fn);
    else
        a_var = whos('-file', fn);
        n_a_var = numel(a_var);
        idx = find(strcmp({a_var.name}, vn), 1, 'first');
        if((n_a_var==1)||(isempty(idx)))
            idx = 1;
        end
        
        [nx, ny, nz] = ilm_vect_assign(a_var(idx).size);
    end
end