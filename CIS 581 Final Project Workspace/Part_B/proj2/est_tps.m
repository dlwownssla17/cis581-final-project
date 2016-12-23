function[a1, ax, ay, w] = est_tps(ctr_pts, target_value)
N = size(target_value, 1);

% create v
v = [target_value; zeros(3, 1)];

% compute K = U(norms)
K = radial_basis_kernel(ctr_pts, ctr_pts);

% create P
P = [ctr_pts, repelem(1, N)'];

% create big matrix
big_mat = [K, P; P', zeros(3)];

% compute TPS parameters
params = pinv(big_mat) * v;

a1 = params(end);
ax = params(end - 2);
ay = params(end - 1);
w = params(1:N);
end

function[U] = radial_basis_kernel(coords1, coords2)
norms_squared = diff_comb(coords1(:, 1), coords2(:, 1)) .^ 2 + ...
    diff_comb(coords1(:, 2), coords2(:, 2)) .^ 2;
nonzeros = find(norms_squared ~= 0);
U = zeros(size(norms_squared));
U(nonzeros) = -norms_squared(nonzeros) .* log(norms_squared(nonzeros));
end
