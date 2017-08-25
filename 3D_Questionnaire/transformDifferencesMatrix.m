function [difference_mat, tree2folder_ind] = transformDifferencesMatrix(tree)
% Gal Mishne, 2016

[mean_mat,~,tree2folder_ind] = transformAveragesMatrix(tree);

difference_mat = zeros(size(mean_mat));
difference_mat(1,:) = mean_mat(1,:);
fold_row = 2;
for level = length(tree)-1 : -1: 1
    for fold_ind = 1:tree{level}.folder_count
        parent_fold_ind = tree{level}.super_folders(fold_ind);
        parent_row = tree2folder_ind(:,1)==(level+1) & tree2folder_ind(:,2)==parent_fold_ind;
        difference_mat(fold_row,:) = mean_mat(fold_row,:) - mean_mat(parent_row,:);
        fold_row = fold_row+1;
    end
end