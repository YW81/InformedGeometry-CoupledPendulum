function [ Trees, dual_aff, init_aff, embedding, TreesExport, embeddingExport] = ...
    RunGenericDimsQuestionnaireFromAff( params, data, init_aff, dim_order)
% Runs questionnaire algorithm using trees built by PCA clustering
% Author: Hadas Benisty
% 14.2.2016
%
% Updated: Gal Mishne, Aug 2017
% Runs Questionnaire based on input affinities.
% Export history of trees and of embeddings, 
%
% Inputs:
%     params - struct array with all user parameters
%     data - M-by-N matrix whose columns are N points in R^M (optional)
%
% Outputs:
%     row_tree, col_tree - the resulting partition trees, given as cells of
%         struct arrays
%--------------------------------------------------------------------------
if any(isnan(data)) == true
    warning('Data contains NaN!');
    data(isnan(data)) = 0;
end

dims = ndims(data);
if params.data.to_normalize,
    data = NormalizeData(data, params.data);
    if params.verbose == 2
        figure, imagesc(data(:,:,1)), colormap gray, axis on, title('Normalized Data'), colorbar;
    end
end
Trees     = cell(dims, 1);
embedding = cell(dims, 1);
dual_aff  = cell(dims, 1);

embeddingExport = cell(params.n_iters+1,dims, 1);
TreesExport = cell(params.n_iters+1,dims, 1);
iter = 1;

% disp('Init')
%%
for dimi = dim_order
    %disp('Tree')
    if  ~params.tree{dimi}.runOnEmbdding
        [Trees{dimi},vals, vecs]  = params.tree{dimi}.buildTreeFun(init_aff{dimi}, params.tree{dimi});%, init_dist{dimi});
        embedding{dimi} = vecs*vals;
    else
        [vecs, vals] = CalcEigs(threshold(init_aff{dimi}, params.init_aff{dimi}.thresh)    , params.tree{dimi}.eigs_num);
        embedding{dimi} = vecs*vals;
        distEmbedding = squareform(pdist(embedding{dimi}));
        Trees{dimi} = params.tree{dimi}.buildTreeFun(distEmbedding, params.tree{dimi});
    end
    TreesExport{iter,dimi} = Trees{dimi};
    embeddingExport{iter,dimi} = embedding{dimi};
end

%%
if params.verbose == 2
    figure;
    for dimi = dim_order
        subplot(dims,1,dimi);
        imagesc(init_aff{dimi});axis image;colorbar;title(['Dim No. ' num2str(dimi) ' - Initial Affin.']);
    end
    if params.savePlot
        filename = [params.filename 'affinity_init.png'];
        saveas(gcf,filename);
    end
    figure;
    for dimi = dim_order
        subplot(dims,1,dimi);
        plotTreeWithColors(Trees{dimi}, 1:length(init_aff{dimi}));
        title(['Dim No. ' num2str(dimi) ' -  Tree (Init )']);
    end
    if params.savePlot
        filename = [params.filename 'tree_init.png'];
        saveas(gcf,filename);
    end
    figure;
    for dimi = dim_order
        if params.tree{dimi}.runOnEmbdding || exist('embedding','var')
            subplot(dims,1,dimi);
            PlotEmbedding(embedding{dimi}, 1:size(init_aff{dimi},1),  ['Dim No. ' num2str(dimi) ' - Initial'] );
        end
    end
    if params.savePlot
        filename = [params.filename 'embedding_init.png'];
        saveas(gcf,filename);
    end
    
    h_tree = figure;
    h_embed = figure;
end

%%
for ii = 1:params.n_iters
    %disp(['iter=' num2str(ii)])
    for dimi = dim_order
        %disp(['dim=' num2str(dimi)])
        otherdims = setdiff(dims:-1:1, dimi);
        %disp('Affinity')
        %         dual_aff{dimi} = feval(params.tree{dimi}.CalcAffFun, permute(data, [2 3 1]), Trees{[3 2]}, params.emd{otherdims}, params.emd{dimi});
        [dual_aff{dimi}] = CalcEmdAff(data, Trees, params.emd, dimi);
        %         Temp = CalcEmdAff(data, Trees, params.emd, dimi);
        %         dual_aff{dimi} = params.tree{dimi}.CalcAffFun(permute(data, [otherdims dimi]), Trees{sort(otherdims,'descend')}, params.emd{otherdims}, params.emd{dimi}, params.verbose);
        
        %disp('Tree')
        if  ~params.tree{dimi}.runOnEmbdding
            [Trees{dimi}, vals, vecs]  = params.tree{dimi}.buildTreeFun(dual_aff{dimi}, params.tree{dimi});
            embedding{dimi} = vecs*vals;
        else
            [vecs, vals] = CalcEigs(dual_aff{dimi}, params.tree{dimi}.eigs_num);
            embedding{dimi} = vecs*vals;
            distEmbedding = squareform(pdist(embedding{dimi}));
            Trees{dimi} = params.tree{dimi}.buildTreeFun(distEmbedding, params.tree{dimi});
        end
        if params.verbose == 2
            figure(h_tree)
            subplot(dims,1,dimi);
            plotTreeWithColors(Trees{dimi}, 1:length(dual_aff{dimi}));
            title(['Dim No. ' num2str(dimi) ' -  Tree (Iteration ', num2str(ii),')']);
            drawnow;
            
            figure(h_embed)
            subplot(dims,1,dimi);
            PlotEmbedding(embedding{dimi}, 1:size(init_aff{dimi},1),  ['Dim No. ' num2str(dimi) ' - Tree (Iteration ', num2str(ii),')'] );
            drawnow;
        end
        TreesExport{iter+ii,dimi} = Trees{dimi};
        embeddingExport{iter+ii,dimi} = embedding{dimi};
    end
    if params.verbose == 2 && params.savePlot
        filename = [params.filename 'tree_iter' num2str(ii) '.png'];
        saveas(h_tree,filename);
        filename = [params.filename 'embed_iter' num2str(ii) '.png'];
        saveas(h_embed,filename);
    end
end

%%
if params.verbose == 2
    if params.n_iters >= 1
        % plot final affins
        figure;
        for dimi = 1:dims
            subplot(dims,1,dimi);
            imagesc(dual_aff{dimi});axis image;colorbar;title(['Dim No. ' num2str(dimi) ' - Final Affin.']);
        end
        if params.savePlot
            filename = [params.filename 'affinity_final.png'];
            saveas(gcf,filename);
        end
    end
    
    figure;
    for dimi = 1:dims
        if params.tree{dimi}.runOnEmbdding || exist('embedding','var')
            subplot(dims,1,dimi);
            PlotEmbedding(embedding{dimi}, 1:size(init_aff{dimi},1),  ['Dim No. ' num2str(dimi) ' - Final '] );
        end
    end
    if params.savePlot
        filename = [params.filename 'embedding_final.png'];
        saveas(gcf,filename);
    end
end

end


