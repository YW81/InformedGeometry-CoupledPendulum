function [mean_mat, d, tree2folder_ind] = transformAveragesMatrix(tree)
% Gal Mishne, 2016

[sum_mat,tree2folder_ind] = transformSumsMatrix(tree);

d = sum(sum_mat,2);
mean_mat = bsxfun(@rdivide,sum_mat,d);