function resultImg = seamlessCloningPoisson(sourceImg, targetImg, mask, offsetX, offsetY)
sourceImg = double(sourceImg);
targetImg = double(targetImg);
[targetH, targetW, ~] = size(targetImg);
indexes = getIndexes(mask, targetH, targetW, offsetX, offsetY);
coefM = getCoefMatrix(indexes);
solVectorRed = getSolutionVect(indexes, sourceImg(:, :, 1), targetImg(:, :, 1), offsetX, offsetY);
solVectorGreen = getSolutionVect(indexes, sourceImg(:, :, 2), targetImg(:, :, 2), offsetX, offsetY);
solVectorBlue = getSolutionVect(indexes, sourceImg(:, :, 3), targetImg(:, :, 3), offsetX, offsetY);
red = mldivide(coefM, solVectorRed');
green = mldivide(coefM, solVectorGreen');
blue = mldivide(coefM, solVectorBlue');
resultImg = uint8(reconstructImg(indexes, red, green, blue, targetImg));
end