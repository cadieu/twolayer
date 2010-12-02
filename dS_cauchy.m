% dS_cauchy.m - derivative of sparse cost function - cauchy distribution
%
% function sparse_cost = dS_cauchy(u,beta,sigma)
%

function sparse_cost = dS_cauchy(a,beta,sigma)

sparse_cost = 2*beta*(1./(1+(a/sigma).^2)).*(a./sigma.^2);