function [aff_mat, emd_mat] = calcEmdAff2DRef(data, ref_data, tree, params, knn)
% Gal Mishne, 2016

if ~isfield(params,'doL1')
    params.doL1 = true;
end

[coefs, ref_coefs] = calcEmdTransform(data, tree, params, ref_data);

if nargin < 5
    if params.doL1
        emd_mat = pdist2(ref_coefs',coefs','cityblock');
    else
        emd_mat = pdist2(ref_coefs',coefs','euclidean');
    end
else
    emd_mat = pdist2(ref_coefs',coefs','cityblock','Smallest',knn);
end

eps     = params.eps * median(emd_mat(:));
aff_mat = exp(-emd_mat / eps);