function E = edgeLink(M, J, theta)
M = M .* J;
J_max = max(M(:));
threshold_high_const = 0.15;
threshold_low_const = 0.001;
threshold_high = threshold_high_const * J_max;
threshold_low = threshold_low_const * J_max;
M(M > threshold_high) = 1;
M(M < threshold_low) = 0;
tangent_sin = sin(theta + pi / 2); % for tangent
tangent_cos = cos(theta + pi / 2); % for tangent
tangent_sin(tangent_sin < sin(15/8 * pi)) = 1;
tangent_sin(sin(15/8 * pi) <= tangent_sin & tangent_sin < sin(1/8 * pi)) = 0;
tangent_sin(sin(1/8 * pi) <= tangent_sin) = -1;
tangent_cos(cos(3/8 * pi) <= tangent_cos) = 1;
tangent_cos(cos(5/8 * pi) <= tangent_cos & tangent_cos < cos(3/8 * pi)) = 0;
tangent_cos(tangent_cos < cos(5/8 * pi)) = -1;
[nr,nc] = size(M);
[col,row] = meshgrid(1:nc,1:nr); % generate row and col indices
row_offset1 = row + tangent_cos;
col_offset1 = col + tangent_sin;
offset1 = row_offset1 > 0 & col_offset1 > 0;
row_offset2 = row - tangent_cos;
col_offset2 = col - tangent_sin;
offset2 = row_offset2 > 0 & col_offset2 > 0;
M = stabilize(M, 0, sum(M(:) == 1), row_offset1, col_offset1, offset1, ...
                row_offset2, col_offset2, offset2, nr, nc, threshold_low); % stabilize
E = M == 1;
end

% recursive helper function that stabilizes given M based on given offsets
% and threshold
function M_next = stabilize(M, prev, curr, row_offset1, col_offset1, offset1, ...
                        row_offset2, col_offset2, offset2, nr, nc, threshold_low)
if prev == curr
    M_next = M;
else
    for r = 2:nr - 1
        for c = 2:nc - 1
            if M(r,c) == 1 && offset1(r,c) == 1
                M(M(row_offset1(r,c), col_offset1(r,c)) > threshold_low) = 1;
            end
            if M(r,c) == 1 && offset2(r,c) == 1
                M(M(row_offset2(r,c), col_offset2(r,c)) > threshold_low) = 1;
            end      
        end
    end
    M_next = stabilize(M, curr, sum(M(:) == 1), row_offset1, col_offset1, offset1, ...
                        row_offset2, col_offset2, offset2, nr, nc, threshold_low);
end
end