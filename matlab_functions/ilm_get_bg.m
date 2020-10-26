function[bg_o] = ilm_get_bg(im, bg_opt, bg)
    bg_o = 0;
    switch (bg_opt) 
        case 1
            bg_o = min(im(:));
        case 2
            bg_o = max(im(:));
        case 3
            bg_o = mean(im(:));
        case 4
            bg_o = 0.5*(mean(im(:)) + min(im(:)));
        case 5
            bg_o = 0.5*(mean(im(:)) + max(im(:)));
        case 6
            bg_o = bg;
        case 7
            bg_o = 0;
    end
end