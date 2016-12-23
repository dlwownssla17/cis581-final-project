% build mapping from triangles to barycentric coordinate matrix (or its
% inverse)
function[matrices] = barycentric_matrices(im_pts, TRI, inverse)
if nargin < 3
    inverse = false;
end

num_triangles = size(TRI, 1);
matrices = zeros(num_triangles, 3, 3);
for i = 1:num_triangles
    a = im_pts(TRI(i, 1), :)';
    b = im_pts(TRI(i, 2), :)';
    c = im_pts(TRI(i, 3), :)';
    bc_matrix = [[a, b, c]; repelem(1, 3)];
    if inverse
        bc_matrix = inv(bc_matrix);
    end
    matrices(i, :, :) = bc_matrix;
end
end