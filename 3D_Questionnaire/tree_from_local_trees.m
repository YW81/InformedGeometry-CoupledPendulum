function dfs_levels = tree_from_local_trees(local_trees, tree, level)
% Merge local trees from level into global tree
% Gal Mishne, 2016

if ~exist('level','var')
    level = length(tree) - 2;
end
  
clustering_all = [];
local_height = max(cellfun(@length,local_trees));
add_2_clustering = zeros(local_height,1);

for i = 1:length(local_trees)
    
    inds = find(tree{level}.clustering == i);
    clustering = cellfun(@(x) x.clustering,local_trees{i},'UniformOutput',false);
    clustering = cell2mat(clustering');
    clustering(1,:) = inds;
    this_height = size(clustering,1);
    if this_height < local_height
        diff_h = local_height - this_height;
        temp = repmat(clustering(end,:),diff_h,1);
        clustering = [clustering ; temp ];
    end
    
%     clustering(local_height,:) = i;
    clustering = bsxfun(@plus,clustering, add_2_clustering);
    
    for l = (level+1):length(tree)
        clustering = [clustering; tree{l}.clustering(inds)] ;
    end
    
    clustering_all = [clustering_all, clustering];
    add_2_clustering(2:local_height) = max(clustering(2:local_height,:),[],2);
end
%%
[~,sorted_inds] = sort(clustering_all(1,:));
clustering_all = clustering_all(:,sorted_inds);
%%
for i = 1:size(clustering_all,1)-1
    
    dfs_levels{i}.folder_count = max(clustering_all(i,:));
    dfs_levels{i}.clustering = clustering_all(i,:);  
    for j = 1:dfs_levels{i}.folder_count
        inds = find(dfs_levels{i}.clustering == j);
        dfs_levels{i}.folder_sizes(j) = length(inds); 
        dfs_levels{i}.super_folders(j) =  clustering_all(i+1,inds(1));
    end
end

%%
dfs_levels{size(clustering_all,1)}.folder_count = 1;
dfs_levels{size(clustering_all,1)}.folder_sizes = size(clustering_all,2);
dfs_levels{size(clustering_all,1)}.clustering = clustering_all(end,:);  
dfs_levels{size(clustering_all,1)}.super_folders = [];

%%
[~, dfs_levels] = relabel(dfs_levels);