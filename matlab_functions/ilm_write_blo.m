% Write blo file
function [] = ilm_write_blo(path_fn, data, info)
    % Ivan Lobato, Ivanlh20@gmail.com 
    % April 2018
    % This code was written using the reverse engineered
    data = permute(data, [2, 1, 4, 3]);
    [info.DP_SZ, ~, info.NX, info.NY] = size(data);
    n_data = info.NX*info.NY;
    
    data = reshape(data, info.DP_SZ, info.DP_SZ, []);

    info.Data_offset_2 = info.Data_offset_1 + n_data;
    
    [fid, ~] = fopen(path_fn, 'w');

    fwrite(fid, info.ID, ['6*', info.type('ID')]);
    fwrite(fid, info.MAGIC, info.type('MAGIC'));
    fwrite(fid, info.Data_offset_1, info.type('Data_offset_1'));
    fwrite(fid, info.Data_offset_2, info.type('Data_offset_2'));
    fwrite(fid, info.UNKNOWN1, info.type('UNKNOWN1'));
    fwrite(fid, info.DP_SZ, info.type('DP_SZ'));
    fwrite(fid, info.DP_rotation, info.type('DP_rotation'));
    fwrite(fid, info.NX, info.type('NX'));
    fwrite(fid, info.NY, info.type('NY'));
    fwrite(fid, info.Scan_rotation, info.type('Scan_rotation'));
    fwrite(fid, info.SX, info.type('SX'));
    fwrite(fid, info.SY, info.type('SY'));
    fwrite(fid, info.Beam_energy, info.type('Beam_energy'));
    fwrite(fid, info.SDP, info.type('SDP'));
    fwrite(fid, info.Camera_length, info.type('Camera_length'));
    fwrite(fid, info.Acquisition_time, info.type('Acquisition_time'));
    fwrite(fid, info.Centering, ['8*', info.type('Centering')]);
    fwrite(fid, info.Distortion, ['14*', info.type('Distortion')]);
    
    A_zeros = zeros(1, info.Data_offset_1 - ftell(fid), info.dtype);
    fwrite(fid, A_zeros, info.dtype);

    im_mean = squeeze(mean(reshape(data, [], info.NX, info.NY), 1));
    im_mean = eval([info.dtype, '(im_mean)']);
    fwrite(fid, im_mean, info.dtype);
    
    for ik=1:n_data
        idx = typecast(int32(ik-1), info.dtype);
        line = [[170, 85, idx], reshape(data(:, :, ik), 1, [])];
        fwrite(fid, line, info.dtype);
    end
    fclose(fid);
end