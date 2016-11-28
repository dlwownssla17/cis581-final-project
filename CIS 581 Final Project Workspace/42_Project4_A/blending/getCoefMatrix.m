function coefM = getCoefMatrix(indexes)
[nr, nc] = size(indexes);
n = numel(find(indexes));
coefM = diag(repmat(4, 1, n));
for r = 1:nr
    replacementIdx = find(indexes(r, :));
    for i = 1:length(replacementIdx)
        c = replacementIdx(i);
        neighborsIdx = [r - 1, c; r + 1, c; r, c - 1; r, c + 1];
        for iNb = 1:size(neighborsIdx, 1)
            rNb = neighborsIdx(iNb, 1);
            cNb = neighborsIdx(iNb, 2);
            if rNb >= 1 && rNb <= nr && cNb >= 1 && cNb <= nc && indexes(rNb, cNb) ~= 0
                coefM(indexes(r, c), indexes(rNb, cNb)) = -1;
            end
        end
    end
end
end
