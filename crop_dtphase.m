function [dtphase, avalind] = crop_dtphase(Z,m,p)

sind = 1 + floor(rand*p.load_segments)*p.segment_szt;
eind = sind + p.segment_szt - 1;
phase = angle(Z(:,sind:eind));
a = abs(Z(:,sind:eind));

[dtphase, avalind] = calc_dtphase(a,phase,m,p);