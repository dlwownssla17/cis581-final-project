function [Iy, E] = rmHorSeam(I, My, Tby)
% I is the image. Note that I could be color or grayscale image.
% My is the cumulative minimum energy map along horizontal direction.
% Tby is the backtrack table along horizontal direction.
% Iy is the image removed one row.
% E is the cost of seam removal

[ny, nx, nz] = size(I);
rmIdx = zeros(1, nx);
Iy = uint8(zeros(ny-1, nx, nz));

%% Add your code here

[E, rmIdx(end)] = min(My(:, end));
for j = (nx - 1):-1:1
    rmIdx(j) = rmIdx(j + 1) + (Tby(rmIdx(j + 1), j + 1) - 2);
end

for j = 1:nx
    Iy(:, j, :) = [I(1:(rmIdx(j) - 1), j, :); I((rmIdx(j) + 1):end, j, :)];
end
end