% descs1 is a 64x(n1) matrix of double values
% descs2 is a 64x(n2) matrix of double values
% match is n1x1 vector of integers where match(i) points to the index of the
% descriptor in descs2 that matches with the descriptor descs1(:,i).
% If no match is found, match(i) = -1

function [match] = feat_match(descs1, descs2)
n1 = size(descs1, 2);
match = -ones(n1, 1);
for i = 1:n1
    diffs = bsxfun(@minus, descs1(:, i), descs2);
    ssd = sum(diffs .^ 2, 1);
    [ssd_sorted, ssd_sorted_idx] = sort(ssd, 2);
    if ssd_sorted(1) / ssd_sorted(2) < 0.6
        match(i) = ssd_sorted_idx(1);
    end
end
end