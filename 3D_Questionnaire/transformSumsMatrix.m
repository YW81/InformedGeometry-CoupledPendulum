function [sum_mat, tree2folder_ind] = transformSumsMatrix(tree)
% Gal Mishne, 2016

n_folders = sum(cellfun(@(x) x.folder_count,tree));
sum_mat = zeros(n_folders,tree{1,1}.folder_count);
tree2folder_ind = zeros(n_folders,2);
k = 1;
for level = length(tree) : -1: 1
    for fold_ind = 1:tree{level}.folder_count
        inds = tree{level}.clustering == fold_ind;
        sum_mat(k,inds) = 1;
        tree2folder_ind(k,1) = level;
        tree2folder_ind(k,2) = fold_ind;
        k = k+1;
        
    end
end

return