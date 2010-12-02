function [dtphase, avalind] = calc_dtphase(a,phase,m,p)

dtphase = [phase(:,1) diff(phase,1,2)];
dtphase = dtphase+ -2*pi*sign(dtphase).*round(abs(dtphase)./(2*pi));

avalind = a>p.phasetrans.a_thresh;
avalind = avalind & [false(m.N,1) avalind(:,1:end-1)];