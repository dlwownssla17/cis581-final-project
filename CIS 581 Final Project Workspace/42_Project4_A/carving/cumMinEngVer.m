function [Mx, Tbx] = cumMinEngVer(e)
% e is the energy map.
% Mx is the cumulative minimum energy map along vertical direction.
% Tbx is the backtrack table along vertical direction.

[ny,nx] = size(e);
Mx = zeros(ny, nx);
Tbx = zeros(ny, nx);
Mx(1,:) = e(1,:);

%% Add your code here

for i = 2:ny
    M1 = [NaN, Mx(i - 1, 1:(end - 1))];
    M2 = Mx(i - 1, :);
    M3 = [Mx(i - 1, 2:end), NaN];
    [minM, Tbx(i, :)] = min([M1; M2; M3]);
    Mx(i, :) = e(i, :) + minM;
end
end