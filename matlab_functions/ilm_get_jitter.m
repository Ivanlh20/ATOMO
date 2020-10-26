function[dxy] = ilm_get_jitter(im_s, im_m)
    im_s = im_s.';
    im_m = im_m.';
    
    [ny, nx] = size(im_s);
    dxy = zeros(nx, 2);
    
    [im_sy, im_sx] = gradient(im_s);  
    im_ms = im_m-im_s;
    for ir = 1:ny
        dxy(ir, :) = [im_sx(:, ir), im_sy(:, ir)]\im_ms(:, ir);
    end   
end

% function[dx, dy] = ilm_get_jitter(im_s, im_m, dx_i, dy_i)
%     im_s = im_s.';
%     im_m = im_m.';
%     
%     [ny, nx] = size(im_s);
%     dxy = zeros(nx, 2);
%     [im_sy, im_sx] = gradient(im_s);  
% 
%     im_ms = im_m-im_s;
%     for ir = 1:ny
%         A = [im_sx(:, ir), im_sy(:, ir)];
%         At = transpose(A);
%         br = At*im_ms(:, ir);
%         Ar = At*A;
%         br = br - Ar*[dx_i(ir); dy_i(ir)];
%         
%         alpha = mean(abs(diag(Ar)));
%         Ar = Ar/alpha;
%         br = br/alpha;
%         
%         Ar = Ar + 20*eye(2);
%         dxy(ir, :) = Ar\br;
% %         dxy(ir, :) = [im_sx(:, ir), im_sy(:, ir)]\im_ms(:, ir);
%     end
%     dx = dxy(:, 1)+dx_i;
%     dy = dxy(:, 2)+dy_i;    
% end