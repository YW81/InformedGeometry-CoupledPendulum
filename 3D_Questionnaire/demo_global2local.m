close all;
clear;

nrows = 180;
ncols = 150;

y = (1:nrows) * 2 * pi / nrows;
x = (1:ncols) * 2 * pi / ncols;

[X,Y] = meshgrid(x,y);

matrix = sin((X+Y+2.*X.*Y)/2);
matrix = matrix(randperm(nrows),randperm(ncols));

params = SetGenericDimsQuestParams(ndims(matrix), false);
params.n_iters  = 2;
params.savePlot = false;
[Trees, dual_aff, init_aff, embedding, TreesExport, embeddingExport] = RunGenericDimsQuestionnaire(params, matrix);
%% plot progression of organization over quest iterations
figure;
nplots = size(TreesExport,1);
row_order_diff = zeros(nplots,nrows);
col_order_diff = zeros(nplots,ncols);
row_order_tree = zeros(nplots,nrows);
col_order_tree = zeros(nplots,ncols);

for i = 1:nplots
    [row_order_diff(i,:), col_order_diff(i,:)] = OrganizeDiffusion(matrix, embeddingExport{i,1}, embeddingExport{i,2} );
    [~, row_order_tree(i,:), col_order_tree(i,:) ] = OrganizeDataByTree(matrix, TreesExport{i,1}, TreesExport{i,2});
end
%
for i = 1:nplots
    organized_data_tree = matrix(row_order_tree(i,:), col_order_tree(i,:) );
    organized_data_diff = matrix(row_order_diff(i,:), col_order_diff(i,:) );
    subplot(2,nplots,i)
    imagesc(organized_data_diff), axis on
    title('Diffusion org')
    
    subplot(2,nplots,nplots+i)
    imagesc(organized_data_tree), axis on
    title('Tree org')
end

plotTreesData(matrix,Trees{1},Trees{2})

%% Local tree refinement 

col_tree_height = length(Trees{2});
local_col_level = col_tree_height-2;

[col_subTrees, col_data_stacked, local_col_order,local_col_level] = ...
    global2local_cols(Trees{2}, matrix,params, dual_aff, local_col_level);
local_sub_col_trees = cellfun(@(x) x{2},col_subTrees,'UniformOutput',false);
joint_local_col_tree = tree_from_local_trees(local_sub_col_trees, Trees{2}, local_col_level);

row_tree_height = length(Trees{1});
local_row_level = row_tree_height-2;
[row_subTrees, row_data_stacked, local_row_order,local_row_level] = ...
    global2local_rows(Trees{1}, matrix,params, dual_aff, local_row_level);
local_sub_row_trees = cellfun(@(x) x{1},row_subTrees,'UniformOutput',false);
joint_local_row_tree = tree_from_local_trees(local_sub_row_trees, Trees{1}, local_row_level);

%% plots
figure;
subplot(131)
imagesc(matrix), axis on
title('Original Data Matrix')
subplot(132)
imagesc(organized_data_tree), axis on
title('Global Tree Organization')
subplot(133)
imagesc(matrix(local_row_order,local_col_order));
title('Refined Local Tree Organization')
axis on;
colormap gray

plotTreesData(matrix,joint_local_row_tree,joint_local_col_tree)
