function coeffs = transformDifference(data,tree)
% Gal Mishne, 2016

[nrows,ncols,~] = size(data);
if nrows == length(tree{1}.clustering)
    row_avg_mat = transformDifferencesMatrix(tree);
    coeffs = row_avg_mat * data;
elseif ncols == length(tree{1}.clustering)
    col_avg_mat = transformDifferencesMatrix(tree);
    coeffs = data * col_avg_mat^T;
else
    error('tree does not match data size')
end
return