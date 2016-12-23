function M = nonMaxSup(J, theta)
[nr,nc] = size(J);
[col,row] = meshgrid(1:nc,1:nr); % generate row and col indices
row_bound1 = round(row + sin(theta));
row_bound2 = round(row - sin(theta));
col_bound1 = round(col + cos(theta));
col_bound2 = round(col - cos(theta));
in_bounds = 0 < row_bound1 & row_bound1 < nr & 0 < row_bound2 & row_bound2 < nr & ...
    0 < col_bound1 & col_bound1 < nc & 0 < col_bound2 & col_bound2 < nc; % bounds
M = zeros(nr,nc);
for r = 2:nr - 1
    for c = 2:nc - 1
       M(r,c) = in_bounds(r,c) == 1 && J(r,c) > J(row_bound1(r,c),col_bound1(r,c)) && ...
           J(r,c) > J(row_bound2(r,c),col_bound2(r,c));
    end
end
end