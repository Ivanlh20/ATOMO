function[system_conf]=ilm_dflt_system_conf(device)
    if(nargin<2)
        device = 2;
    end
    
    system_conf.precision = 1; % eP_Float = 1, eP_double = 2
    system_conf.device = device; % eD_CPU = 1, eD_GPU = 2
    system_conf.cpu_nthread = 1;
    system_conf.gpu_device  = 0;
end
