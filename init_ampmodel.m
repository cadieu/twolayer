function [m, p] = init_ampmodel(Z_store,m,p)

a = abs(Z_store); clear Z_store
LOGA = zeros(size(a),'single');
a_thresh = p.firstlayer.a_thresh;
LOGA(a>a_thresh) = log(a(a>a_thresh));
LOGA(a<=a_thresh) = log(a_thresh);
clear a

loga_means = zeros(m.N,1);
loga_factors = zeros(m.N,1);
% zero mean each dim, and set variance to .1;
for i = 1:size(LOGA,1)
    loga_mean = mean(LOGA(i,:));
    LOGA(i,:) = LOGA(i,:) - loga_mean;
    loga_factor = sqrt(1/(10*var(LOGA(i,:))));
    LOGA(i,:) = LOGA(i,:)*loga_factor;
    
    loga_means(i) = loga_mean;
    loga_factors(i) = loga_factor;
end

m.loga_means = loga_means;
m.loga_factors = loga_factors;

if ~isfield(m,'Acoords')
    m = fit_Acoords(m);
end