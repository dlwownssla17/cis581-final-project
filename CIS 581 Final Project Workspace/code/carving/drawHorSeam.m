function [Iy, E] = drawHorSeam(I, My, Tby)
nx = size(I, 2);
rmIdx = zeros(1, nx);
Iy = uint8(I);

[E, rmIdx(end)] = min(My(:, end));
for j = (nx - 1):-1:1
    rmIdx(j) = rmIdx(j + 1) + (Tby(rmIdx(j + 1), j + 1) - 2);
end

for j = 1:nx
    Iy(rmIdx(j), j, 1) = 255;
end
end