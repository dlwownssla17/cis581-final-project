function[morphed_im] = morph(im1, im2, im1_pts, im2_pts, warp_frac, dissolve_frac)
% read in images and extract their dimensions
I1 = im2double(im1);
I2 = im2double(im2);
[row1, col1, ~] = size(I1);
[row2, col2, ~] = size(I2);

% scale source image and its set of corresponding points to dimensions of
% target image
I1_scaled = imresize(I1, [row2 col2]);
im1_pts_scaled = im1_pts(:, :);
im1_pts_scaled(:, 1) = (col2 ./ col1) .* im1_pts_scaled(:, 1);
im1_pts_scaled(:, 2) = (row2 ./ row1) .* im1_pts_scaled(:, 2);

% build coordinates of target image
[X, Y] = meshgrid(1:col2, 1:row2);
P = [X(:), Y(:)];
num_points = size(P, 1);
pixel_vectors = [P'; repelem(1, num_points)];

M = size(warp_frac, 2);
morphed_im = cell(1, M);
for i = 1:M
    warp_param = warp_frac(i);
    dissolve_param = dissolve_frac(i);
    
    % compute warp corresponding points
    im_warp_pts = (1 - warp_param) .* im1_pts_scaled + warp_param .* im2_pts;
    
    % compute delaunay triangles for image
    TRI = delaunay(im_warp_pts(:, 1), im_warp_pts(:, 2));
    T = tsearchn(im_warp_pts, TRI, P);
    
    % build mapping from triangle to barycentric coordinate matrix based on
    % moving and fixed images
    bc_matrices1 = barycentric_matrices(im1_pts_scaled, TRI);
    bc_matrices2 = barycentric_matrices(im2_pts, TRI);
    bc_matrices1_per_point = barycentric_matrices_per_point(bc_matrices1, T);
    bc_matrices2_per_point = barycentric_matrices_per_point(bc_matrices2, T);
    morphed_x1 = squeeze(bc_matrices1_per_point(:, 1, :))';
    morphed_y1 = squeeze(bc_matrices1_per_point(:, 2, :))';
    morphed_z1 = squeeze(bc_matrices1_per_point(:, 3, :))';
    morphed_x2 = squeeze(bc_matrices2_per_point(:, 1, :))';
    morphed_y2 = squeeze(bc_matrices2_per_point(:, 2, :))';
    morphed_z2 = squeeze(bc_matrices2_per_point(:, 3, :))';
    
    % build mapping from triangle to inverse of barycentric coordinate
    % matrix based on warped image
    bc_matrices_inv = barycentric_matrices(im_warp_pts, TRI, true);
    bc_matrices_inv_per_point = barycentric_matrices_per_point(bc_matrices_inv, T);
    warp_x1 = squeeze(bc_matrices_inv_per_point(:, 1, :))';
    warp_y1 = squeeze(bc_matrices_inv_per_point(:, 2, :))';
    warp_z1 = squeeze(bc_matrices_inv_per_point(:, 3, :))';
    
    % compute barycentric coordinates and perform inverse warping
    prod_x = sum(warp_x1 .* pixel_vectors);
    prod_y = sum(warp_y1 .* pixel_vectors);
    prod_z = sum(warp_z1 .* pixel_vectors);
    bc_coeffs = [prod_x; prod_y; prod_z];
    src_x1 = sum(morphed_x1 .* bc_coeffs);
    src_y1 = sum(morphed_y1 .* bc_coeffs);
    src_z1 = sum(morphed_z1 .* bc_coeffs);
    src_x2 = sum(morphed_x2 .* bc_coeffs);
    src_y2 = sum(morphed_y2 .* bc_coeffs);
    src_z2 = sum(morphed_z2 .* bc_coeffs);
    
    % divide by z
    src_x1 = round(min(col2, max(1, src_x1 ./ src_z1)));
    src_y1 = round(min(row2, max(1, src_y1 ./ src_z1)));
    src_x2 = round(min(col2, max(1, src_x2 ./ src_z2)));
    src_y2 = round(min(row2, max(1, src_y2 ./ src_z2)));
    
    % create morphed image components
    morphed_im1 = zeros(row2, col2, 3);
    morphed_im2 = zeros(row2, col2, 3);
    for j = 1:num_points
        morphed_im1(P(j, 2), P(j, 1), :) = I1_scaled(src_y1(j), src_x1(j), :);
        morphed_im2(P(j, 2), P(j, 1), :) = I2(src_y2(j), src_x2(j), :);
    end
    
    % blend according to dissolve_param
    morphed_im{i} = im2uint8((1 - dissolve_param) .* morphed_im1 + dissolve_param .* morphed_im2);
end
end