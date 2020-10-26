% read video file as 3d stack
function[data, info]=ilm_read_video(file_name, idx_0, idx_e, sym_crop)
    if(nargin<4)
        sym_crop = false;
    end

    info = ilm_read_info_video(file_name, sym_crop);

    idx_0 = ilm_set_bound(idx_0, 1, info.n_data);
    idx_e = ilm_set_bound(idx_e, 1, info.n_data);
    
    n_data_sel = idx_e - idx_0;
    
    ax = info.ix_0:info.ix_e;
    ay = info.iy_0:info.iy_e;
    
%     videoFReader = vision.VideoFileReader(file_name, 'VideoOutputDataType', info.dtype, 'ImageColorSpace', 'Intensity');
    videoFReader = VideoReader(file_name);
    data = zeros(info.ny, info.nx, n_data_sel, info.dtype);
    ic = 1;
    for ik = idx_0:idx_e
%         im_ik = videoFReader();
        im_ik = read(videoFReader, ik);
        im_ik = im_ik(:, :, 1);
        data(:, :, ic) = im_ik(ay, ax);
        ic = ic + 1;
    end 
end