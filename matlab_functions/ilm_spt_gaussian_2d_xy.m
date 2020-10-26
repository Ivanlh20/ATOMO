function[im] = ilm_spt_gaussian_2d_xy(xy, A, sigma, lx, ly, nx, ny, pre, dev)
    if(nargin<9)
        dev = 2;
    end
    
    if(nargin<8)
        pre = 1;
    end
    
    if(nargin<7)
        ny = ly;
    end
    
    if(nargin<6)
        nx = lx;
    end
    
    system_conf.precision = pre;                     % eP_Float = 1, eP_double = 2
    system_conf.device = dev;                        % eD_CPU = 1, eD_GPU = 2
    system_conf.cpu_nthread = 1; 
    system_conf.gpu_device  = 0;

    n_data = size(xy, 1);
    data = zeros(n_data, 4);
    data(:, 1:2) = xy;
    data(:, 3) = A;
    data(:, 4) = sigma;

    %%%%%%%%%%%%%%%%%%%%% 1 %%%%%%%%%%%%%%%%%%%%%%%%
    superposition.ff_sigma = 6.0;
    superposition.nx = nx;
    superposition.ny = ny;
    superposition.dx = lx/nx;
    superposition.dy = ly/ny;
    superposition.data = data;

    im = ilc_spt_gauss_2d(system_conf, superposition);
end