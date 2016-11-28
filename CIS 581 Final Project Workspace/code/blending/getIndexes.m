function indexes = getIndexes(mask, targetH, targetW, offsetX, offsetY)
indexes = zeros(targetH, targetW);
count = 0;
for i = 1:size(mask, 1)
    replacementIdx = find(mask(i, :));
    indexes(offsetY + i, replacementIdx + offsetX) = count + (1:length(replacementIdx));
    count = count + length(replacementIdx);
end
end
