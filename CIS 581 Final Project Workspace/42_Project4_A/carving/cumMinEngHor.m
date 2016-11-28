function [My, Tby] = cumMinEngHor(e)
% e is the energy map.
% My is the cumulative minimum energy map along horizontal direction.
% Tby is the backtrack table along horizontal direction.

[ny,nx] = size(e);
My = zeros(ny, nx);
Tby = zeros(ny, nx);
My(:,1) = e(:,1);

%% Add your code here

for j = 2:nx
    M1 = [NaN; My(1:(end - 1), j - 1)];
    M2 = My(:, j - 1);
    M3 = [My(2:end, j - 1); NaN];
    [minM, Tby(:, j)] = min([M1, M2, M3], [], 2);
    My(:, j) = e(:, j) + minM;
end
end