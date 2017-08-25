function [coefs, test_coefs] = calcEmdTransform(data, tree, params, test_data)
% Gal Mishne, 2016

[averages_mat,folder_sizes,tree2folder_ind] = transformAveragesMatrix(tree);
coefs = averages_mat * data;

nrows = size(data,1);
folder_sizes = folder_sizes/nrows;

if isfield(params,'doWeighted') && params.doWeighted == true
    [differences_mat] = tree_difference_matrix(tree);
    diff_coefs = differences_mat * data;
    if strcmp(params.weightsType,'norm')
        weights = sqrt(sum(diff_coefs.^2,2)); 
    elseif strcmp(params.weightsType,'var')
        weights = var(diff_coefs,0,2);
    else
        error('no such weight type exists for EMD')
    end
else
    weights = (folder_sizes.^params.beta) .* 2.^(-(length(tree)-tree2folder_ind(:,1))*params.alpha);
end
weights = spdiags(weights,0,size(averages_mat,1),size(averages_mat,1));

coefs = weights * coefs;

if nargout > 1 && nargin > 3
    test_coefs = averages_mat * test_data;
    test_coefs = weights * test_coefs;
end
