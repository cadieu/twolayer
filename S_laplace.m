% S_laplace.m - sparse cost function - laplace distribution
%
% function sparse_cost = S_laplace(a,beta,sigma)
%

function sparse_cost = S_laplace(a,beta)

sparse_cost = beta*abs(a);