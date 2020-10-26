function[files, n_files]=ilm_dir(path_dir, fs)
%     Copyright 2019 Ivan Lobato <Ivanlh20@gmail.com>
%     you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version of the License, or
%     (at your option) any later version.
%     This code is distributed in the hope that it will be useful, 
%     but WITHOUT ANY WARRANTY;without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%     GNU General Public License for more details.

    path_dir = ilm_add_filesep(path_dir);
    files = dir([path_dir, fs]);
    files = strcat(path_dir, {files.name}.');
    files = ilm_sort_files(files);
    
    if(nargout>1)
        n_files = size(files, 1);
    end
end