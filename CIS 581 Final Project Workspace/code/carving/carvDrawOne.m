function [Ic, T] = carvDrawOne(I, drawHor, drawVer)
[ny, nx, nz] = size(I);
T = zeros(drawHor+1, drawVer+1);
TI = cell(drawHor+1, drawVer+1);
TI{1,1} = I;

Te = cell(drawHor + 1, drawVer + 1);
Te{1,1} = genEngMap(I);

for i = 1:(drawHor + 1)
    for j = 1:(drawVer + 1)
        if i == 1 && j == 1
            continue;
        end
        
        if i > 1
            IPrevy = TI{i - 1, j};
            ePrevy = Te{i - 1, j};
            [My, Tby] = cumMinEngHor(ePrevy);
            [Iy, Ey] = drawHorSeam(IPrevy, My, Tby);
        end
        
        if j > 1
            IPrevx = TI{i, j - 1};
            ePrevx = Te{i, j - 1};
            [Mx, Tbx] = cumMinEngVer(ePrevx);
            [Ix, Ex] = drawVerSeam(IPrevx, Mx, Tbx);
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

Ic = TI{drawHor+1,drawVer+1};

end