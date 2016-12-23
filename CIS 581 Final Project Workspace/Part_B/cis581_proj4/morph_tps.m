function[morphed_im] = morph_tps(im_source, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y, ctr_pts, sz)
row = sz(1);
col = sz(2);
[X, Y] = meshgrid(1:col, 1:row);
P = [X(:), Y(:)];
num_points = size(P, 1);

% compute TPS model
U = radial_basis_kernel(P, ctr_pts);
src_x = a1_x + ax_x .* P(:, 1) + ay_x .* P(:, 2) + (w_x' * U)';
src_y = a1_y + ax_y .* P(:, 1) + ay_y .* P(:, 2) + (w_y' * U)';
src_x = round(min(col, max(1, src_x)));
src_y = round(min(row, max(1, src_y)));

% compute values for each pixel
morphed_im = zeros(row, col, 3);
for i = 1:num_points
    morphed_im(P(i,2), P(i,1), :) = im_source(src_y(i), src_x(i), :);
end
end