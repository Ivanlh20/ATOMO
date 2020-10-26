function[mtf] = ilm_create_mtf_g(mtf_par, nx, ny)
    if(nargin<3)
        ny = mtf_par.ny;
    end
    
    if(nargin<2)
        nx = mtf_par.nx;
    end  
    
    nxh = nx/2;
    nyh = ny/2;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %The parameterization is given fractions of Nyquist frequency = 1/(2*dx)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % g_nyquist = 1/(2*dx) = nx/(2*lx) = nx*dgx/2 = 1 --> gdx = 2/nx;
    % 
    dgx = 2/nx;
    dgy = 2/ny;
    [gx, gy] = meshgrid((-nxh:(nxh-1))*dgx, (-nyh:(nyh-1))*dgy);
    g = sqrt(gx.^2+gy.^2);
    
    % matlab sinc function is defines as sin(pi x)/(pi x)
%     mtf = mtf_par.fun(g);
    mtf_g = ilm_eval_rad_mtf(mtf_par.coef, g);
    mtf = mtf_g.*sinc(gx/2).*sinc(gy/2);
end