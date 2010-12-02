% dS_laplace.m - derivative sparse cost function - laplace distribution
%
% function sparse_cost = dS_laplace(a,beta)
%

function sparse_cost = dS_laplace(a,beta)

sparse_cost = beta*sign(a);