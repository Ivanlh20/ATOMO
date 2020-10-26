function[data, n_data] = ilm_read_ser_or_dm(path)
    [~, ~, ext] = fileparts(path);
    if(strcmpi(ext, '.ser'))
        data = ilm_read_ser(path);    
    else
        data = ilm_read_dm(path);
    end
    
    if(nargout>1)
        n_data = size(data, 3);
    end
end