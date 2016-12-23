function[morphed_im] = morph_tps_wrapper(im1, im2, im1_pts, im2_pts, warp_frac, dissolve_frac)
% read in images and extract their dimensions
I1 = im2double(im1);
I2 = im2double(im2);
[row1, col1, ~] = size(I1);
[row2, col2, ~] = size(I2);
sz = [row2, col2];

% scale source image and its set of corresponding points to dimensions of
% target image
I1_scaled = imresize(I1, [row2 col2]);
im1_pts_scaled = im1_pts(:, :);
im1_pts_scaled(:, 1) = (col2 ./ col1) .* im1_pts_scaled(:, 1);
im1_pts_scaled(:, 2) = (row2 ./ row1) .* im1_pts_scaled(:, 2);

M = size(warp_frac, 2);
morphed_im = cell(1, M);
for i = 1:M
    warp_param = warp_frac(i);
    dissolve_param = dissolve_frac(i);
    
    % compute warp correspondings points
    im_warp_pts = (1 - warp_param) .* im1_pts_scaled + warp_param .* im2_pts;
    
    % compute TPS parameters
    [a1_x1, ax_x1, ay_x1, w_x1] = est_tps(im_warp_pts, im1_pts_scaled(:, 1));
    [a1_y1, ax_y1, ay_y1, w_y1] = est_tps(im_warp_pts, im1_pts_scaled(:, 2));
    [a1_x2, ax_x2, ay_x2, w_x2] = est_tps(im_warp_pts, im2_pts(:, 1));
    [a1_y2, ax_y2, ay_y2, w_y2] = est_tps(im_warp_pts, im2_pts(:, 2));
    
    % create morphed components using TPS parameters
    morphed_im1 = morph_tps(I1_scaled, a1_x1, ax_x1, ay_x1, w_x1, a1_y1, ax_y1, ay_y1, w_y1, im_warp_pts, sz);
    morphed_im2 = morph_tps(I2, a1_x2, ax_x2, ay_x2, w_x2, a1_y2, ax_y2, ay_y2, w_y2, im_warp_pts, sz);
    
    % blend according to dissolve_param
    morphed_im{i} = im2uint8((1 - dissolve_param) .* morphed_im1 + dissolve_param .* morphed_im2);
end
end
