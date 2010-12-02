% dS_gauss.m - derivative of cost function - Gaussian distribution
%
% function dcost = dS_gauss(u,beta)
%

function dcost = dS_gauss(a,beta)

dcost = beta*a;