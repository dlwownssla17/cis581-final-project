function[U] = radial_basis_kernel(coords1, coords2)
norms_squared = diff_comb(coords1(:, 1), coords2(:, 1)) .^ 2 + diff_comb(coords1(:, 2), coords2(:, 2)) .^ 2;
nonzeros = find(norms_squared ~= 0);
U = zeros(size(norms_squared));
U(nonzeros) = -norms_squared(nonzeros) .* log(norms_squared(nonzeros));
end