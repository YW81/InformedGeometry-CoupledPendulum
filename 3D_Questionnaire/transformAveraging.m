function coeffs = transformAveraging(data,tree)
% Gal Mishne, 2016

[nrows,ncols,~] = size(data);
if nrows == length(tree{1}.clustering)
    row_avg_mat = transformAveragesMatrix(tree);
    coeffs = row_avg_mat * data;
elseif ncols == length(tree{1}.clustering)
    col_avg_mat = transformAveragesMatrix(tree);
    coeffs = data * col_avg_mat^T;
else
    error('tree does not match data size')
end
return