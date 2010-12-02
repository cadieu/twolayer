% Slow.m - slowness penalty on coeff amplitudes
%

function S = Slow(a)

S=diff(a,1,2).^2;
