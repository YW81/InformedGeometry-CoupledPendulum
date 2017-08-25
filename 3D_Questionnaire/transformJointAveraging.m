function coeffs = transformJointAveraging(data,row_tree,col_tree)
% Gal Mishne, 2016

[nrows,ncols,~] = size(data);

if nrows ~= length(row_tree{1}.clustering) || ...
        ncols ~= length(col_tree{1}.clustering)
    error('Tree size must match # rows and # cols in data');
end

row_avg_mat = transformAveragesMatrix(row_tree);
coeffs = row_avg_mat * data;
col_avg_mat = transformAveragesMatrix(col_tree);
coeffs = coeffs * col_avg_mat^T;
return

