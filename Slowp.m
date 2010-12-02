% Slowp.m - slowness penalty derivative
%

function Sp = Slowp(a)

D=diff(a,1,2);

Sp=[-D(:,1) -diff(D,1,2) D(:,end)];
