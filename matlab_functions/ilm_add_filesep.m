function[path_dir]=ilm_add_filesep(path_dir)
    [~, fn, ~] = fileparts(path_dir);
    path_dir = ilm_ifelse(~isempty(fn), [path_dir, filesep], path_dir);
end