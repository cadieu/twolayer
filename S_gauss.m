% S_gauss.m - cost function - Gaussian distribution
%
% function cost = S_gauss(u,beta)
%

function cost = S_gauss(a,beta)

cost = .5*beta*a.^2;