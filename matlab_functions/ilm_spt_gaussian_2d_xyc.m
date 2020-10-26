function[im] = ilm_spt_gaussian_2d_xyc(xyc, A, sigma, lx, ly, nx, ny)
    system_conf.precision = 1;                     % eP_Float = 1, eP_double = 2
    system_conf.device = 2;                        % eD_CPU = 1, eD_GPU = 2
    system_conf.cpu_nthread = 1; 
    system_conf.gpu_device  = 0;

    
    n_data = size(xyc, 1);
    if(numel(A) == 1)
       A = A*ones(n_data, 1); 
    end
    
    data = zeros(n_data, 4);
    data(:, 1:2) = xyc(:, 1:2);
    data(:, 3) = A*xyc(:, 3);
    data(:, 4) = sigma;

    %%%%%%%%%%%%%%%%%%%%% 1 %%%%%%%%%%%%%%%%%%%%%%%%
    superposition.ff_sigma = 4.5;
    superposition.nx = nx;
    superposition.ny = ny;
    superposition.dx = lx/nx;
    superposition.dy = ly/ny;
    superposition.data = data;

    im = ilc_spt_gauss_2d(system_conf, superposition);
end