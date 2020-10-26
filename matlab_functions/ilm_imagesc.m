function [] =ilm_imagesc(idx_fig, im, cmap)
    if(nargin<3)
        cmap = 'gray';
    end
    figure(idx_fig);
    imagesc(im);
    axis image;
    eval(['colormap ', cmap]);
end