function plotTreesData(matrix,row_tree,col_tree)
[nrows,ncols] = size(matrix);

[~, row_order] = sort(row_tree{2}.clustering);
[~, col_order] = sort(col_tree{2}.clustering);

figure;
subplot(3,3,[4,7])
plotTreeWithColors(row_tree,1:nrows);
colorbar off
camroll(90)
title('Row Tree','Position',[0.5, 1.03, 0],'Rotation',90);

subplot(3,3,[2,3])
plotTreeWithColors(col_tree, 1:ncols);
colorbar off
title('Col tree');

ax=subplot(3,3,[5,6,8,9]);
imagesc(matrix(row_order,col_order));colormap(ax,gray)
title('Data organized by joint trees')