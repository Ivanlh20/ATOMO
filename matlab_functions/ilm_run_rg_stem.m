function [at_p] = ilm_run_rg_stem(system_conf, data, p, sigma_g, at_p, nit_ri)
    if(nargin<6)
        nit_ri = 1;
    end
    
    if(nargin<5)
        at_p = ilm_fd_tr_2d_bi(system_conf, data, p, sigma_g);
    end
    
    % number of Nelder-Mead iterations
    nit_nm = 10;
    
    % number of iterations between consecutive images
    nit_bci = 1;
    
    % calculate border
    bd = 0.75*ilm_calc_borders_using_at_v(at_p, 1);
	
    % correct drift between images
    at_p = ilm_fd_tr_scy_shx_2d_bi(system_conf, data, p, sigma_g, bd, at_p, nit_bci, nit_nm);

    % calculate border
    bd = 0.75*ilm_calc_borders_using_at_v(at_p, 1);
    
    % correct drift using average image
    at_p = ilm_fd_tr_scy_shx_2d_ri(system_conf, data, p, sigma_g, bd, at_p, nit_ri, nit_nm);
end