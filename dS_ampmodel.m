function output = dS_ampmodel(loga,loga_hat,m,p)

a = exp(bsxfun(@plus,bsxfun(@rdivide,loga,m.loga_factors),m.loga_means));
output = bsxfun(@times,p.ampmodel.loga_noise_factor*m.loga_factors,(loga-loga_hat)./(a+.001));