% y1, x1, y2, x2 are the corresponding point coordinate vectors Nx1 such
% that (y1i, x1i) matches (x2i, y2i) after a preliminary matching

% thresh is the threshold on distance used to determine if transformed
% points agree

% H is the 3x3 matrix computed in the final step of RANSAC

% inlier_ind is the nx1 vector with indices of points in the arrays x1, y1,
% x2, y2 that were found to be inliers

function [H, inlier_ind] = ransac_est_homography(x1, y1, x2, y2, thresh)
max_inliers = get_max_inliers(x1, y1, x2, y2, thresh, 100);
inlier_ind = find(max_inliers)';
H = est_homography(x1(max_inliers), y1(max_inliers), x2(max_inliers), y2(max_inliers));
end

function [max_inliers] = get_max_inliers(x1, y1, x2, y2, thresh, iter)
max_inliers_size = -Inf;
for i = 1:iter
    rand_idx = randperm(size(x1, 1), 4);
    homography = est_homography(x1(rand_idx), y1(rand_idx), x2(rand_idx), y2(rand_idx));
    [x1_h, y1_h] = apply_homography(homography, x2, y2);
    inliers = (x1_h - x1) .^ 2 + (y1_h - y1) .^ 2 <= thresh .^ 2;
    inliers_size = sum(inliers);
    if inliers_size > max_inliers_size
        max_inliers = inliers;
        max_inliers_size = inliers_size;
    end
end
end