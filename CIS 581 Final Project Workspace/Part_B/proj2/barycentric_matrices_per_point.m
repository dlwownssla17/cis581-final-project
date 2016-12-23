function[matrices] = barycentric_matrices_per_point(barycentric_matrices, T)
matrices = zeros(size(T, 1), 3, 3);
not_nan = ~isnan(T);
matrices(find(not_nan), :, :) = barycentric_matrices(T(not_nan), :, :);
end