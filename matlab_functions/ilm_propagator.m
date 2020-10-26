function [prop] = ilm_propagator(g2, gmax, E_0, z)
    emass = 510.99906;
    hc = 12.3984244;
    lambda = hc/sqrt(E_0*(2*emass + E_0));
    prop = exp(-1i*pi*lambda*z*g2); 
    prop(g2>gmax^2) = 0;
end