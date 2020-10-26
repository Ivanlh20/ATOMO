function[im_w] = ilm_apply_wiener_filter_ast(im_n, im_d)
    if(nargin<3)
        opt = 1;
    end

    [ny, nx] = size(im_n); 
    nxh = nx/2;
    nyh = ny/2;
    [gx, gy] = meshgrid((-nxh):(nxh-1), (-nyh):(nyh-1));
    g2 = ifftshift(gx.^2+gy.^2);
    g2_max = min([nx, ny]/2)^2;
    ig2 = g2>g2_max;
    
    im_n = ilc_anscombe_forward(im_n);
    im_d = ilc_anscombe_forward(im_d);

    F = abs(fft2(ifftshift(im_d))).^2;
    N = abs(fft2(ifftshift(im_n-im_d))).^2;
    H = F./(F+N);
%     H(ig2) = 0;
    im_w = real(fftshift(ifft2(H.*fft2(ifftshift(im_n)))));
    
    im_w = ilc_anscombe_inverse(im_w);

%     im_w = (im_w-mean(im_w(:)))/std(im_w(:));
%     im_w = im_w*im_std + im_mean;
%     

    if(min(im_n(:))>0)
        im_w = max(0, im_w); 
    end
end