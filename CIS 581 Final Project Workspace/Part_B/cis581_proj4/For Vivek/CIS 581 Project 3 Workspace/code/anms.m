% Adaptive Non-Maximal Suppression
% cimg = corner strength map
% max_pts = number of corners desired
% [x, y] = coordinates of corners
% rmax = suppression radius used to get max_pts corners

function [x, y, rmax] = anms(cimg, max_pts)
cimg_corners = bsxfun(@times, imregionalmax(cimg), cimg);
[y, x] = ind2sub(size(cimg_corners), find(cimg_corners));
num_corners = size(y, 1);
max_pts = min([max_pts, num_corners]);
radius = Inf(num_corners, 1);
for i = 1:num_corners
   for j = 1:num_corners
       if cimg_corners(y(i), x(i)) < cimg_corners(y(j), x(j))
           dist = sqrt((y(j) - y(i))^2 + (x(j) - x(i))^2);
           radius(i) = min([radius(i), dist]);
       end
   end
end
[radius, radius_idx] = sort(radius);
x    = x(radius_idx(end - max_pts + 1:end));
y    = y(radius_idx(end - max_pts + 1:end));
rmax = radius(end - max_pts + 1:end);
end