function[diffs] = diff_comb(a, b)
diffs = bsxfun(@minus, a', b);
end