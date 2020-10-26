function [T] = PCTF(g2, gmax, E_0, cs3, f, sf, beta)
emass = 510.99906;
hc = 12.3984244;
lambda = hc/sqrt(E_0*(2*emass + E_0));
lambda2 = lambda*lambda;
cs3 = cs3*1.0e+07;
beta = beta*1.0e-03;
chi = pi*lambda*g2.*(0.5*cs3*lambda2*g2-f);
chi = exp(-1j*chi);
u = 1.0 + (pi*beta*sf)^2*g2;
sE = -(0.25*(pi*lambda*sf*g2).^2 + (pi*beta)^2*g2.*(cs3*lambda2*g2-f).^2)./u;
T = chi.*exp(sE);
g2max = gmax^2;
T(g2>g2max) = 0.0;