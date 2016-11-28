function [Ix, E] = drawVerSeam(I, Mx, Tbx)
ny = size(I, 1);
rmIdx = zeros(ny, 1);
Ix = uint8(I);

[E, rmIdx(end)] = min(Mx(end, :));
for i = (ny - 1):-1:1
    rmIdx(i) = rmIdx(i + 1) + (Tbx(i + 1, rmIdx(i + 1)) - 2);
end

for i = 1:ny
    Ix(i, rmIdx(i), 1) = 255;
end
end