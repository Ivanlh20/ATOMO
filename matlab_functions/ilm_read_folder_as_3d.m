 function[data, fn_list]=ilm_read_folder_as_3d(path_dir, fs)
    [~, fn, ~] = fileparts(path_dir);
    path_dir = ilm_ifelse(~isempty(fn), [path_dir, filesep], path_dir);
    if(~strcmpi(path_dir(end), '\'))
        path_dir = [path_dir, '\'];
    end
    fn_list = dir([path_dir, fs]);
    fn_list = {fn_list.name};
    fs = erase(fs, '*');
    str_angles = erase(fn_list, fs);
    n_files = numel(str_angles);
    labels = zeros(n_files, 1);
    data = [];
    for ik=1:n_files
        [data_ik, n_data] = ilm_read_ser_or_dm([path_dir, fn_list{ik}]);
        data = cat(3, data, data_ik);
        str = char(str_angles(ik));
        str = str(~isletter(str));
        str = erase(str, '_');
        labels(ik) = str2double(str);
    end
    [labels, idx] = sort(labels);
    data = data(:, :, idx);
    fn_list = fn_list(idx);
    fn_list = strcat(path_dir, fn_list).';
end