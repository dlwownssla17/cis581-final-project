function [Ic, T] = carv(I, nr, nc)
% I is the image being resized
% [nr, nc] is the numbers of rows and columns to remove.
% Ic is the resized image
% T is the transport map

[ny, nx, nz] = size(I);
T = zeros(nr+1, nc+1);
TI = cell(nr+1, nc+1);
TI{1,1} = I;
% TI is a trace table for images. TI{r+1,c+1} records the image removed r rows and c columns.

%% Add your code here

Te = cell(nr + 1, nc + 1);
Te{1,1} = genEngMap(I);

for i = 1:(nr + 1)
    for j = 1:(nc + 1)
        if i == 1 && j == 1
            continue;
        end
        
        if i > 1
            IPrevy = TI{i - 1, j};
            ePrevy = Te{i - 1, j};
            [My, Tby] = cumMinEngHor(ePrevy);
            [Iy, Ey] = rmHorSeam(IPrevy, My, Tby);
        end
        
        if j > 1
            IPrevx = TI{i, j - 1};
            ePrevx = Te{i, j - 1};
            [Mx, Tbx] = cumMinEngVer(ePrevx);
            [Ix, Ex] = rmVerSeam(IPrevx, Mx, Tbx);
        end
        
        if j == 1 || (i > 1 && T(i - 1, j) + Ey < T(i, j - 1) + Ex)
            T(i, j) = T(i - 1, j) + Ey;
            TI{i, j} = Iy;
            Te{i, j} = genEngMap(Iy);
        else
            T(i, j) = T(i, j - 1) + Ex;
            TI{i, j} = Ix;
            Te{i, j} = genEngMap(Ix);
        end
    end
end

Ic = TI{nr+1,nc+1};

end