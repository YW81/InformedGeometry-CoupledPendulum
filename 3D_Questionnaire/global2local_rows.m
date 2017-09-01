function [row_subTrees, row_data_stacked, local_row_order,local_row_level] = ...
    global2local_rows(row_tree,matrix,params,dual_aff,local_row_level)
% Perform local refinement of row tree by local-organization 
% of each branch in row_tree at row_level
% Gal Mishne 2016

[nrows,ncols] = size(matrix);

tree_height = length(row_tree);
if nargin < 6
    local_row_level = tree_height-3;
    n_folders = row_tree{local_row_level}.folder_count;
    if n_folders > 10
        local_row_level = local_row_level + 1;
    end
end

n_folders = row_tree{local_row_level}.folder_count;
local_row_order = [];
row_data_stacked = {};
row_subTrees = {};
local_row_params = params;
local_row_params.verbose = 0; 
%%
disp(['Row tree, level ' num2str(local_row_level) ' level ' num2str(n_folders)])

for i = 1:n_folders
    row_inds = find(row_tree{local_row_level}.clustering == i);
    sub_data = matrix(row_inds,:);
    
    
    sub_init_aff{1} = dual_aff{1}(row_inds,row_inds);
    sub_init_aff{2} = dual_aff{2};
    
    [subTrees] = RunGenericDimsQuestionnaireFromAff( local_row_params, sub_data , sub_init_aff, [2,1]);
    row_subTrees{i} = subTrees;
    
    [organized_data_tree,sub_row_order,~] = OrganizeDataByTree(sub_data, subTrees{1}, subTrees{2});
    row_data_stacked{end+1,1} = zeros(10,ncols);
    row_data_stacked{end+1,1} = organized_data_tree;
    
    local_row_order = [local_row_order row_inds(sub_row_order)];
end

%%
figure
imagesc(cell2mat(row_data_stacked));colormap(gray)
title('Local row organizations')
return