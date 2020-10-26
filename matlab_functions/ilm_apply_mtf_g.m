function[im] = ilm_apply_mtf_g(mtf_g, im_i)
    im = fft2(ifftshift(im_i)).*ifftshift(mtf_g);
    im = max(0, real(fftshift(ifft2(im))));
end