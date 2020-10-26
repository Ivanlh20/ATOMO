% find shifting between images
function [at_p] = ilm_fd_tr_2d_bi_tem(system_conf, st, p, sigma_g, radius, bd_0, at_p0, n_it)
    if(isfield(st,'psi'))
        psi = st.psi;
    else
        psi = complex(zeros(ny, nx));
    end
    
    if(nargin<8)
        n_it = 1;
    end
    
    if(nargin<7)
        at_p0 = ilm_dflt_at_p(n_data);
    end
    
    if(nargin<6)
        bd_0 = zeros(1, 4);
    end
    
     b_fit = true;
     
    % convert affine transformation to consecutive images
    
    at_p = ilm_cvt_at_v_r_2_at_v_bci(at_p0);
    
    % find shift between images
    dx = 1; 
    dy = 1;
    for it = 1:n_it
        for ik = 2:n_data 
            tic;
            at_b = at_p(ik, :);
            bd_t = ilm_at_v_2_bd(st.nx, st.ny, bd_0, at_p0(ik-1, :));
            bd_ik = ilm_set_borders(at_b(5:6)); 
            bd = max(bd_t, bd_ik);
            [A, txy] = ilm_cvt_at_v_2_A_txy(at_b);
            
            psi = m_psi_ik.*exp(1i*angle(psi));
            if(ik < st.n_data)
                psi = ifft2(fft2(psi).*st.Pg);
            else
                psi = ifft2(fft2(psi).*st.Pg_b);
            end
            m_psi_r = double(abs(psi).^2);
            m_psi_ik = double(st.m2_psi(:, :, ik));
            at_p(ik, 5:6) = ilc_fd_tr_2d(system_conf, m_psi_r, m_psi_ik, dx, dy, A, txy, p, sigma_g, bd, 1, 0, b_fit, radius);
            t_c = toc;
            
            disp(['iter = ', num2str(it), ' calculating shift between images #', num2str(ik-1), '_', num2str(ik), '_time=', num2str(t_c, '%5.2f')]);

%             ilm_show_pcf(system_conf, double(data(:, :, ik-1)), double(data(:, :, ik)), at_b, at_p(ik, :), p, sigma_g, bd);
        end
    end
    % transform affine transformations related to the reference image   
    at_p = ilm_cvt_at_v_bci_2_at_v_r(at_p);     
end