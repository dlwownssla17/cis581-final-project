function [Ix, E] = rmVerSeam(I, Mx, Tbx)
% I is the image. Note that I could be color or grayscale image.
% Mx is the cumulative minimum energy map along vertical direction.
% Tbx is the backtrack table along vertical direction.
% Ix is the image removed one column.
% E is the cost of seam removal

[ny, nx, nz] = size(I);
rmIdx = zeros(ny, 1);
Ix = uint8(zeros(ny, nx-1, nz));

%% Add your code here

[E, rmIdx(end)] = min(Mx(end, :));
for i = (ny - 1):-1:1
    rmIdx(i) = rmIdx(i + 1) + (Tbx(i + 1, rmIdx(i + 1)) - 2);
end

for i = 1:ny
    Ix(i, :, :) = [I(i, 1:(rmIdx(i) - 1), :), I(i, (rmIdx(i) + 1):end, :)];
end
end