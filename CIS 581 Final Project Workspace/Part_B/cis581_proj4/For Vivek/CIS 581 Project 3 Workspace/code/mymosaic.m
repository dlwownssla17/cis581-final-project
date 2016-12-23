% img_input is a cell array of color images (HxWx3 uint8 values in the
% range [0,255])
% img_mosaic is the output mosaic

function [img_mosaic] = mymosaic(img_input)
max_pts = 500;
merge_ratio = 0.5;
num_img = numel(img_input);
mid = ceil(num_img / 2);
img_mosaic = img_input{mid};
for i = 1:num_img
    if i == mid
        continue;
    end
    if i < mid
        img_next = img_input{mid - i};
    else
        img_next = img_input{i};
    end
    I_mosaic = rgb2gray(img_mosaic);
    I_next = rgb2gray(img_next);
    [r_mosaic, c_mosaic] = size(I_mosaic);
    [r_next, c_next] = size(I_next);
    cimg_mosaic = corner_detector(I_mosaic);
    cimg_next = corner_detector(I_next);
    [x_mosaic, y_mosaic, rmax_mosaic] = anms(cimg_mosaic, max_pts);
    [x_next, y_next, rmax_next] = anms(cimg_next, max_pts);
    descs_mosaic = feat_desc(I_mosaic, x_mosaic, y_mosaic);
    descs_next = feat_desc(I_next, x_next, y_next);
    match = feat_match(descs_mosaic, descs_next);
    x_mosaic = x_mosaic(match ~= -1);
    y_mosaic = y_mosaic(match ~= -1);
    x_next = x_next(match(match ~= -1));
    y_next = y_next(match(match ~= -1));
    [H, inlier_end] = ransac_est_homography(x_mosaic, y_mosaic, x_next, y_next, 5);
    [x_mosaic_h, y_mosaic_h] = apply_homography(H, [1; 1; c_next; c_next], [1; r_next; 1; r_next]);
    min_h = round(min([x_mosaic_h, y_mosaic_h], [], 1));
    max_h = round(max([x_mosaic_h, y_mosaic_h], [], 1));
    [x_idx, y_idx] = meshgrid(min_h(1):max_h(1), min_h(2):max_h(2));
    x_idx = reshape(x_idx, [numel(x_idx), 1]);
    y_idx = reshape(y_idx, [numel(y_idx), 1]);
    [x_next_h, y_next_h] = apply_homography(inv(H), x_idx, y_idx);
    x_next_h = round(x_next_h);
    y_next_h = round(y_next_h);
    valid_idx = 0 < x_next_h & x_next_h <= c_next & 0 < y_next_h & y_next_h <= r_next;
    x_next_h = x_next_h(valid_idx);
    y_next_h = y_next_h(valid_idx);
    x_idx = x_idx(valid_idx);
    y_idx = y_idx(valid_idx);
    min_result = min([min_h; [1, 1]], [], 1);
    max_result = max([max_h; [c_mosaic, r_mosaic]], [], 1);
    range_result = max_result - min_result + 1;
    range_r = range_result(2);
    range_c = range_result(1);
    img_result = zeros(range_r, range_c, 3);
    img_result = uint8(img_result);
    from_mosaic = 1 - min_result .* (min_result ~= 1);
    img_result(from_mosaic(2):(from_mosaic(2) + r_mosaic - 1), from_mosaic(1):(from_mosaic(1) + c_mosaic - 1), :) = img_mosaic;
    for j = 1:length(x_idx)
        if all(img_result(y_idx(j) - min_result(2) + 1, x_idx(j) - min_result(1) + 1, :) == 0)
            img_result(y_idx(j) - min_result(2) + 1, x_idx(j) - min_result(1) + 1, :) = img_next(y_next_h(j), x_next_h(j), :);
        else
            img_result(y_idx(j) - min_result(2) + 1, x_idx(j) - min_result(1) + 1, :) = merge_ratio .* img_result(y_idx(j) - min_result(2) + 1, x_idx(j) - min_result(1) + 1, :) + (1 - merge_ratio) .* img_next(y_next_h(j), x_next_h(j), :);
        end
    end
    img_mosaic = im2uint8(img_result);
end
end