function [loga] = calc_logamp(a,m,p)

loga = zeros(size(a));
loga(a>p.firstlayer.a_thresh) = log(a(a>p.firstlayer.a_thresh));
loga(a<=p.firstlayer.a_thresh) = log(p.firstlayer.a_thresh);

loga = bsxfun(@minus,loga,m.loga_means);
loga = bsxfun(@times,loga,m.loga_factors);
