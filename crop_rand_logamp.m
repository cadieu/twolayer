function [loga] = crop_rand_logamp(Z,m,p)

rind = randperm(size(Z,2));
a = abs(Z(:,rind(1:p.batch_size)));

[loga] = calc_logamp(a,m,p);

loga = bsxfun(@minus,loga,mean(loga,1));