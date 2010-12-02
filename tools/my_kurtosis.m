function [out] = my_kurtosis(X)

mu = mean(X,2);
fourth_mom = mean((X-repmat(mu,1,size(X,2))).^4,2);
sig = var(X,0,2)+eps;
out = fourth_mom./sig.^2 - 3;