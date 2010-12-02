function [loga] = crop_logamp(Z,m,p)

sind = 1 + floor(rand*p.load_segments)*p.segment_szt;
eind = sind + p.segment_szt - 1;
a = abs(Z(:,sind:eind));

[loga] = calc_logamp(a,m,p);