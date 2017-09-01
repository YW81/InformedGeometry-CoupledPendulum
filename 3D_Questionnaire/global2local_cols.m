function [col_subTrees, col_data_stacked, local_col_order,local_col_level] = ...
    global2local_cols(col_tree,matrix,params,dual_aff,local_col_level)
% Perform local refinement of col tree by local-organization 
% of each branch in col_tree at col_level
% Gal Mishne 2016

if nargin < 6
    local_col_level = length(col_tree)-2;
end
%%
[nrows,ncols] = size(matrix);

n_folders = col_tree{local_col_level}.folder_count;
disp(n_folders)
local_col_order = [];
col_data_stacked = {};
col_subTrees = {};

local_col_params = params;
local_col_params.verbose = 0; 

%%
disp(['Col tree, level ' num2str(local_col_level) ' level ' num2str(n_folders)])

for i = 1:n_folders
    col_inds = find(col_tree{local_col_level}.clustering == i);
    sub_data = matrix(:,col_inds);
    
    sub_init_aff{1} = dual_aff{1};
    sub_init_aff{2} = dual_aff{2}(col_inds,col_inds);
    
    [Trees] = RunGenericDimsQuestionnaireFromAff( local_col_params, sub_data , sub_init_aff, [2 1]);
    
    col_subTrees{i} = Trees;
    
    [organized_data_tree,~,sub_col_order] = OrganizeDataByTree(sub_data, Trees{1}, Trees{2});
    col_data_stacked{1,end+1} = zeros(nrows,10);
    col_data_stacked{1,end+1} = organized_data_tree;
    local_col_order = [local_col_order col_inds(sub_col_order)];
    %%
end
figure
imagesc(cell2mat(col_data_stacked));colormap(gray)
title('Local col organizations')
