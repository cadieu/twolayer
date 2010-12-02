function [m, p] = init_phasetrans(Z_store,m,p)

a = abs(Z_store); clear Z_store
asort = sort(a(:),'descend');
p.phasetrans.a_thresh = asort(ceil(p.phasetrans.a_on_fraction*numel(asort)));

if ~isfield(m,'Acoords')
    m = fit_Acoords(m);
end