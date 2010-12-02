function [E, g, Ihat, Ierror] = obj_fun_twolayer(X,I,m,p)

% parse input
sz = size(I,2);
astop = sz*m.N;
a = reshape(X(1:astop),m.N,sz);
phase = reshape(X(astop+1:2*astop),m.N,sz);
wstop = sz*m.L;
w0 = X(2*astop+1:2*astop+wstop);
%w = reshape(w0,m.L,sz);
vstop = sz*m.K;
v0 = X(2*astop+wstop+1:2*astop+wstop+vstop);
%v = reshape(v0,m.K,sz);

% calc second layer inputs
[dtphase,avalind] = calc_dtphase(a,phase,m,p);
[loga] = calc_logamp(a,m,p);

[Ierror, Ihat] = calc_Ierror(I,a,phase,m,p);

[E_phasetrans, dw0, dtphase_hat, ~] = obj_fun_w(w0,dtphase,avalind,m,p);
[E_ampmodel, dv0, loga_hat, ~] = obj_fun_v(v0,loga,m,p);

mse = sum(sum(bsxfun(@times,0.5*m.I_noise_factors,Ierror.^2)));
a_slowness = .5*p.firstlayer.a_lambda_S*sum(sum((Slow(a))));

E = double(mse + a_slowness + p.twolayer.phasetrans_feedback_factor*E_phasetrans + p.twolayer.ampmodel_feedback_factor*E_ampmodel);

%fprintf('\rmse=%2.2e a_slow=%2.2e phasetrans=%2.2e ampmodel=%2.2e\r',mse,a_slowness,p.twolayer.phasetrans_feedback_factor*E_phasetrans,p.twolayer.ampmodel_feedback_factor*E_ampmodel)

if nargout>1
    
    weighted_error = bsxfun(@times,-m.I_noise_factors,Ierror);

    grada = (real(m.A).'*weighted_error).*cos(phase) + (imag(m.A).'*weighted_error).*sin(phase);
    grada = grada + + dS_cauchy(a,p.firstlayer.a_cauchy_beta,p.firstlayer.a_cauchy_sigma) ...
        + p.firstlayer.a_lambda_S*Slowp(a);
    if p.firstlayer.natural_gradient
        gradphase = (imag(m.A).'*weighted_error).*cos(phase) - (real(m.A).'*weighted_error).*sin(phase);
    else
        gradphase = a.*((imag(m.A).'*weighted_error).*cos(phase) - (real(m.A).'*weighted_error).*sin(phase));
    end

    % include feedback gradients
    gradphase= gradphase + p.twolayer.phasetrans_feedback_factor*dS_phasetrans(dtphase,dtphase_hat,avalind,m,p);
    grada = grada + p.twolayer.ampmodel_feedback_factor*dS_ampmodel(loga,loga_hat,m,p);
    
    dw0 = p.twolayer.phasetrans_feedback_factor*dw0;
    dv0 = p.twolayer.ampmodel_feedback_factor*dv0;
    
    g = [reshape(grada,numel(grada),1); reshape(gradphase,numel(gradphase),1); dw0; dv0];
end
