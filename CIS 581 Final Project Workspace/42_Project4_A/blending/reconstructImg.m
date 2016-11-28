function resultImg = reconstructImg(indexes, red, green, blue, targetImg)
resultImg = targetImg;
for r = 1:size(indexes, 1)
    replacementIdx = find(indexes(r, :));
    resultImg(r, replacementIdx, 1) = red(indexes(r, replacementIdx));
    resultImg(r, replacementIdx, 2) = green(indexes(r, replacementIdx));
    resultImg(r, replacementIdx, 3) = blue(indexes(r, replacementIdx));
end
end