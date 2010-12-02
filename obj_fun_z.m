function [E, g, Ihat, Ierror] = obj_fun_z(X,I,m,p)

sz = size(I,2);
astop = sz*m.N;

a = reshape(X(1:astop),m.N,sz);
% deal with negative a
%anegind=a<0;
%a(anegind)=-a(anegind);

phase = reshape(X((astop+1):2*astop),m.N,sz);
%phase = phase + -2*pi*sign(phase).*round(abs(phase)./(2*pi));
%phase(anegind) = -phase(anegind);

[Ierror, Ihat] = calc_Ierror(I,a,phase,m,p);

% Compute Energy Terms
switch p.firstlayer.prior
    case 'cauchy'
        mse = sum(sum(bsxfun(@times,0.5*m.I_noise_factors,Ierror.^2)));
        a_sparsity = sum(S_cauchy(a(:),p.firstlayer.a_cauchy_beta,p.firstlayer.a_cauchy_sigma));
        E= mse + a_sparsity;
    case 'gauss'
        mse = sum(sum(bsxfun(@times,0.5*m.I_noise_factors,Ierror.^2)));
        a_sparsity = sum(S_gauss(a(:),p.firstlayer.a_gauss_beta));
        E= mse + a_sparsity;
    case 'slow_cauchy'
        mse = sum(sum(bsxfun(@times,0.5*m.I_noise_factors,Ierror.^2)));
        a_sparsity = sum(S_cauchy(a(:),p.firstlayer.a_cauchy_beta,p.firstlayer.a_cauchy_sigma));
        a_slowness = .5*p.firstlayer.a_lambda_S*sum(sum((Slow(a))));
        E= mse + a_sparsity + a_slowness;
    case 'slow_gauss'
        mse = sum(sum(bsxfun(@times,0.5*m.I_noise_factors,Ierror.^2)));
        a_sparsity = sum(S_gauss(a(:),p.firstlayer.a_gauss_beta));
        a_slowness = .5*p.firstlayer.a_lambda_S*sum(sum((Slow(a))));
        E= mse + a_sparsity + a_slowness;
end
E = double(E);
if nargout>1
    
    weighted_error = bsxfun(@times,-m.I_noise_factors,Ierror);
    
    grada = (real(m.A).'*weighted_error).*cos(phase) + (imag(m.A).'*weighted_error).*sin(phase);
    if p.firstlayer.natural_gradient
        gradphase = (imag(m.A).'*weighted_error).*cos(phase) - (real(m.A).'*weighted_error).*sin(phase);
    else
        gradphase = a.*((imag(m.A).'*weighted_error).*cos(phase) - (real(m.A).'*weighted_error).*sin(phase));
    end
    
    switch p.firstlayer.prior
        case 'cauchy'
            grada = grada + dS_cauchy(a,p.firstlayer.a_cauchy_beta,p.firstlayer.a_cauchy_sigma);
        case 'gauss'
            grada = grada + dS_gauss(a,p.firstlayer.a_gauss_beta);
        case 'slow_cauchy'
            grada = grada + dS_cauchy(a,p.firstlayer.a_cauchy_beta,p.firstlayer.a_cauchy_sigma) ...
                          + p.firstlayer.a_lambda_S*Slowp(a);
        case 'slow_gauss'
            grada = grada + dS_gauss(a,p.firstlayer.a_gauss_beta) ...
                          + p.firstlayer.a_lambda_S*Slowp(a);
    end
    g = [reshape(grada,numel(grada),1); reshape(gradphase,numel(gradphase),1)];
    
end