% img = double (height)x(width) array (grayscale image) with values in the
% range 0-255
% x = nx1 vector representing the column coordinates of corners
% y = nx1 vector representing the row coordinates of corners
% descs = 64xn matrix of double values with column i being the 64 dimensional
% descriptor computed at location (xi, yi) in im

function [descs] = feat_desc(img, x, y)
n = size(x, 1);
extract_idx = 1:5:40;
img_padded = padarray(im2double(img), [20, 20]);
descs = zeros(64, n);
for i = 1:n
    subsample = img_padded(y(i):y(i) + 39, x(i):x(i) + 39);
    subsample_blurred = imfilter(subsample, fspecial('gaussian'));
    descs_for_point = reshape(subsample_blurred(extract_idx, extract_idx), size(descs(:, i)));
    descs(:, i) = (descs_for_point - mean(descs_for_point)) ./ std(descs_for_point, 1);
end
end