% function to rescale TEM data:
% data: 3d data stack
% N: digitalization
% delta: percentage(0, 1) in order to allow data oscilation
function [data, a, b] = ilm_resc_tem_data(data, N, delta)
    if(nargin<2)
        N = 2^16-1;
    end
    
    if(nargin<3)
        delta = 0.075;
    end
    
    data_min = min(data(:));
    data_max = max(data(:));

    a = N*(1-2*delta)/(data_max-data_min);
    b = -data_min*a + delta*N;
    
    data = a*data + b;
end