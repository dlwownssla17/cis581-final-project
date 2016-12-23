function solVector = getSolutionVect(indexes, source, target, offsetX, offsetY)
[nr, nc] = size(target);
[nrSrc, ncSrc] = size(source);
indexesLogical = indexes ~= 0;

sourceWithOffset = zeros(nr, nc);
sourceWithOffset(offsetY + (1:nrSrc), offsetX + (1:ncSrc)) = source;
gpSum = (sourceWithOffset .* indexesLogical) .* 4;

sourcePad = padarray(source, [1, 1], 'symmetric');
sourcePadZerosRow = zeros(1, ncSrc + 2);
sourcePadZerosCol = zeros(nrSrc + 2, 1);
sourcePadShiftDown = [sourcePadZerosRow; sourcePad(1:(end - 1), :)];
sourcePadShiftUp = [sourcePad(2:end, :); sourcePadZerosRow];
sourcePadShiftRight = [sourcePadZerosCol, sourcePad(:, 1:(end - 1))];
sourcePadShiftLeft = [sourcePad(:, 2:end), sourcePadZerosCol];
gqSumPad = sourcePadShiftDown + sourcePadShiftUp + sourcePadShiftRight + sourcePadShiftLeft;
gqSum = zeros(nr, nc);
gqSum(offsetY + (1:nrSrc), offsetX + (1:ncSrc)) = gqSumPad(2:(end - 1), 2:(end - 1));
gqSum = gqSum .* indexesLogical;

targetPad = padarray(target, [1, 1], 'symmetric');
targetPad = targetPad .* ~padarray(indexesLogical, [1, 1]);
targetPadZerosRow = zeros(1, nc + 2);
targetPadZerosCol = zeros(nr + 2, 1);
targetPadShiftDown = [targetPadZerosRow; targetPad(1:(end - 1), :)];
targetPadShiftUp = [targetPad(2:end, :); targetPadZerosRow];
targetPadShiftRight = [targetPadZerosCol, targetPad(:, 1:(end - 1))];
targetPadShiftLeft = [targetPad(:, 2:end), targetPadZerosCol];
fqSumPad = targetPadShiftDown + targetPadShiftUp + targetPadShiftRight + targetPadShiftLeft;
fqSum = fqSumPad(2:(end - 1), 2:(end - 1));
fqSum = fqSum .* indexesLogical;

solM = gpSum - gqSum + fqSum;
solVector = reshape(solM', [1, numel(solM)]);
solVector = solVector(indexes' ~= 0);
end