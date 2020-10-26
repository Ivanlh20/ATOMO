% Read info video file
function [info] = ilm_read_info_video(file_name, sym_crop)
    if(nargin<2)
        sym_crop = false;
    end
    
    vid = VideoReader(file_name);
    
    info.frame_rate = vid.FrameRate;
    info.n_data = vid.NumberOfFrames;
    info.nx = vid.Width;
    info.ny = vid.Height;
    info.duration = vid.duration;
    info.dtype = 'uint8';
    
    nx_0 = info.nx;
    ny_0 = info.ny;
    
    if(sym_crop)
        nx = ilc_pn_fact(nx_0, 1);
        if(nx>nx_0)
            nx = ilc_pn_fact(nx_0, 2);
        end
        
        ny = ilc_pn_fact(ny_0, 1);
        if(ny>ny_0)
            ny = ilc_pn_fact(ny_0, 2);
        end
        info.nx = min(nx, ny);
        info.ny = info.nx;
    end
    
    info.ix_0 = round((nx_0-info.nx)/2)+1;
    info.ix_e = info.ix_0 + info.nx - 1;
    info.iy_0 = round((ny_0-info.ny)/2)+1;
    info.iy_e = info.iy_0 + info.ny - 1;
end