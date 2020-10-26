% Create tif file from a 3d array
function [] =ilm_write_tif(stack, filename, type_mat, b_norm)
    size_MB_max = 4*1024-32;
%     size_MB_max = 128;
    [ny, nx, nz] = size(stack);
    
    if(nargin==2)
        type_mat = 'uint8';
        b_norm = false;     
    elseif(nargin==3)
        b_norm = false;    
    end

    if(strcmpi(type_mat, 'logical') || strcmpi(type_mat, 'uint8'))
        type_mat = 'uint8';
        BitsPerSample = 8;
    else
        type_mat = 'uint16';
        BitsPerSample = 16;
    end
    
    if(strcmpi(type_mat, 'uint8'))
        id_type_w = 0;
    else
        id_type_w = 1;
    end
    
    [path, filename] = fileparts(filename);
    fn_path = [ilm_add_filesep(path), filename, '.tif'];
    if(exist(fn_path, 'file'))
        delete(filename);
    end
    
    size_type_w = ilm_sizeof(type_mat);
    size_req = nx*ny*nz*size_type_w/1024^2;
    n_chunk = ceil(size_req/size_MB_max);
    
    [a, b] = get_a_b(stack, type_mat, b_norm);

    for idx_chunk = 1:n_chunk
        if(n_chunk==1)
            filename_idx = fn_path;
        else
            filename_idx = [filename, '_', num2str(idx_chunk, '%.3d'), '.tif'];
        end
        [iz_0, iz_e] = ilm_split_range_idx(nz, n_chunk, idx_chunk);
        save_tif(filename_idx, iz_0, iz_e);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    function save_tif(filename, iz_0, iz_e)
        % https://nl.mathworks.com/help/matlab/import_export/exporting-to-images.html
        
        TF = Tiff(filename, 'w');

        tag_struct.ImageLength = ny;
        tag_struct.ImageWidth = nx;
        tag_struct.Photometric = Tiff.Photometric.MinIsBlack;
        tag_struct.BitsPerSample = BitsPerSample;
        tag_struct.RowsPerStrip = 16;
        tag_struct.SamplesPerPixel = 1;
        tag_struct.Compression = Tiff.Compression.PackBits;
        tag_struct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tag_struct.Software = 'MATLAB';
        if(iz_e-iz_0>0)
            tag_struct.SubIFD = 2 ; % required to create subdirectories
        end
        
        im_ik = fn_apply_transform(stack(:, :, iz_0), id_type_w, a, b);
        setTag(TF, tag_struct);
        write(TF, im_ik);
        
        if(iz_e-iz_0>0)
            tag_struct = rmfield(tag_struct, 'SubIFD');
        end
        for ik = (iz_0+1):iz_e
            im_ik = fn_apply_transform(stack(:, :, ik), id_type_w, a, b);
            
            writeDirectory(TF);
            setTag(TF, tag_struct);
            write(TF, im_ik);
        end
        close(TF);
    end
end

function[a, b] = get_a_b(stack, type_mat, b_norm)
    if(b_norm)
        I_min = double(min(stack(:)));
        I_max = double(max(stack(:)));
        a = 1.0/(I_max-I_min);            
        b = -a*I_min;
    else
        a = 1.0;
        b = 0;
    end

    if(isa(stack, 'double') || isa(stack, 'single'))
        if(strcmpi(type_mat, 'uint8'))
            f = 255;
        else
            f = 65535; 
        end
    else
        if(isa(stack, 'uint8') && strcmpi(type_mat, 'uint16'))
            f = 65535/255;
        else
            f = 1.0;
        end
    end
    a = f*a;
    b = f*b;        
end

function[im_o] = fn_apply_transform(im_i, id_type, a, b)
    if (id_type==0)
        im_o = uint8(a*double(im_i)+b); 
    else
        im_o = uint16(a*double(im_i)+b); 
    end
end