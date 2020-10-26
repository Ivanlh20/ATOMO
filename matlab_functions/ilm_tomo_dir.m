function[fn_list, angles] = ilm_tomo_dir(path_dir, fs)
    [~, fn, ~] = fileparts(path_dir);
    path_dir = ilm_ifelse(~isempty(fn), [path_dir, filesep], path_dir);
    fn_list = dir([path_dir, fs]);
    fn_list = {fn_list.name};
    [~, ~, ext] = fileparts(fn_list{1});
    
    fs = erase(fs, '*');  
    str_angles = erase(fn_list, fs);
    
    n_files = numel(str_angles);
    angles = zeros(n_files, 1);
    
%if(~isempty(idx))
% idx = strfind(str, "m");
%end

%if(~isempty(idx))
% idx = strfind(str, "p");
%end
        

    for ik=1:n_files
        str = char(str_angles(ik));
        str = lower(strtrim(str));
        
        if(((str(1)=='m') || (str(1)=='p')) && ~isnan(str2double(str(2:end))))
            if(str(1)=='m')
                str = ['-', str(2:end)];
            else
                str = str(2:end);
            end
        else
            str = str(~isletter(str));
            idx = strfind(str, "-");
            if(~isempty(idx))
                str = str(idx(end):end);
            else
                idx = strfind(str, "+");
                if(~isempty(idx))
                    str = str((idx(end)+1):end);
                else
                    idx = strfind(str, "_");
                    if(~isempty(idx))
                        str_t = str(1:(idx(end)-1));
                        if isnan(str2double(str_t))
                            str = erase(str, "_");
                        else
                            str = str_t;
                        end
                    end
                end
            end
        end
        
        idx = strfind(str, "_");
        if(~isempty(idx)) %#ok<STREMP>
            str = split(str, '_');
            str = str{1};
        end
                    
        angles(ik) = str2double(str);
    end
    [angles, idx] = sort(angles);
    fn_list = fn_list(idx);
    fn_list = strcat(path_dir, fn_list).';
end