function[im_rt] = ilm_nn_stem_data_rt(net, im, w_off, nx_st, ny_st)
    if(nargin<4)
        nx_st = 96; % stride
    end
    
    if(nargin<5)
        ny_st = nx_st; % stride
    end

    if(nargin<3)
        w_off = 1;
    end
    
    % Neural network input size
    nx_nn_i = net.Layers(1).InputSize(2);
    ny_nn_i = net.Layers(1).InputSize(1);

    % border size
    bd_x = 5;
    bd_y = 5;

    % image size
    [ny_im, nx_im] = size(im);

    if((nx_nn_i==ny_im+10)&&(ny_nn_i==nx_im+10))
        im = double(im);
        im = ilc_add_bd_pbc(im, [5, 5]);
        [sft, sc] = ilm_mean_std_np(im);
        imn = (im - sft)/sc;
        imn = reshape(imn, size(imn, 2), size(imn, 1), 1, 1);
        im_r = predict(net, imn, 'ExecutionEnvironment', 'cpu', 'MiniBatchSize', 1); 
        im_rt = double(im_r)*sc+sft;
        return
    end    
    
    ix_im_0 = -bd_x+1;
    ix_im_e = nx_im + bd_x;
    iy_im_0 = -bd_y+1;
    iy_im_e = ny_im + bd_y;
    
    % data preallocation
    n_data = 128;
    data = zeros(ny_nn_i, nx_nn_i, 1, n_data);
    parm(n_data) = struct('ix_0', 0, 'ix_e', 0, 'iy_0', 0, 'iy_e', 0, 'sft', 0, 'sc', 0);
  
    % preallocate output
    im_rt = -1e6*ones(ny_im, nx_im);
    
    fp = 100*n_data/(ceil((ix_im_e-ix_im_0+1)/nx_st)*ceil((iy_im_e-iy_im_0+1)/ny_st));
    ip = 1;
    
    ic = 0;
    ix_0 = ix_im_0;
    while (ix_0<ix_im_e)
        ix_e = ix_0 + nx_nn_i - 1;
        if(ix_e>ix_im_e)
            ix_0 = ix_im_e - nx_nn_i + 1;
            ix_e = ix_im_e;
        end
            
        iy_0 = iy_im_0;
        while(iy_0<iy_im_e)
            iy_e = iy_0 + ny_nn_i - 1;
            if(iy_e>iy_im_e)
            	iy_0 = iy_im_e - ny_nn_i + 1;
            	iy_e = iy_im_e;
            end
        
            % extract region
            im_c = ilm_extract_region(im, ix_0, ix_e, iy_0, iy_e);
            
            % get output area
            ic = ic + 1;
            parm(ic).ix_0 = ix_0 + bd_x;
            parm(ic).ix_e = ix_e - bd_x;
            parm(ic).iy_0 = iy_0 + bd_y;
            parm(ic).iy_e = iy_e - bd_y;
     
            % image preprocessing
            [parm(ic).sft, parm(ic).sc] = ilm_mean_std_np(im_c);
            im_c = (im_c - parm(ic).sft)/parm(ic).sc;
            
            data(:, :, 1, ic) = reshape(im_c, ny_nn_i, nx_nn_i, 1, 1);
            
            if(ic==n_data)
            	im_rt = cnn_processing(net, data, parm, im_rt);
                if(w_off)
                    disp(['percentage = ', num2str(ip*fp, '%5.2f')])
                end
                ip = ip + 1;
                
                ic = 0;
            end
            iy_0 = ilm_ifelse(iy_e==iy_im_e, iy_im_e, iy_0 + ny_st);
        end
        ix_0 = ilm_ifelse(ix_e==ix_im_e, ix_im_e, ix_0 + nx_st);
    end
    
    
    if(ic == 0)
        if(w_off)
            disp(['percentage = ', num2str(100, '%5.2f')])
        end
    elseif(ic<n_data)
        im_rt = cnn_processing(net, data(:, :, :, 1:ic), parm, im_rt);
        if(w_off)
            disp(['percentage = ', num2str(100, '%5.2f')])
        end
    end
end

function[im_rt] = cnn_processing(net, data, parm, im_rt)
    % send data to the CNN
    n_data = size(data, 4);
    data_rt = predict(net, data, 'MiniBatchSize', n_data, 'ExecutionEnvironment', 'gpu');

    % join patches
    for ik=1:n_data
        % squeeze data
        im_r = squeeze(data_rt(:, :, 1, ik));

        % image preprocessing
        im_r = im_r*parm(ik).sc+parm(ik).sft;

        % set selected area
        ax = parm(ik).ix_0:parm(ik).ix_e;
        ay = parm(ik).iy_0:parm(ik).iy_e;

        % average patches
        im_s = im_rt(ay, ax);
        ii_p = im_s > -1e5;
        im_r(ii_p) = 0.5*(im_r(ii_p)+im_s(ii_p));
        im_rt(ay, ax) = im_r;
    end 
end