function [E, g, loga_hat, loga_error] = obj_fun_v(X,loga,m,p)

sz = size(loga,2);
v = reshape(X,m.K,sz);

[loga_error, loga_hat] = calc_loga_error(loga,v,m,p);

% Compute Energy Terms
loga_noise_cost = .5*p.ampmodel.loga_noise_factor*sum(loga_error(:).^2);
switch p.ampmodel.prior
    case 'laplace'
        v_cost  = sum(S_laplace(v(:),p.ampmodel.v_laplace_beta));
    case 'cauchy'
        v_cost  = sum(S_cauchy(v(:),p.ampmodel.v_cauchy_beta,p.ampmodel.v_cauchy_sigma));
    case 'slow_laplace'
        v_cost  = sum(S_laplace(v(:),p.ampmodel.v_laplace_beta)) + .5*p.ampmodel.v_lambda_S*sum(sum(Slow(v)));
    case 'slow_cauchy'
        v_cost  = sum(S_cauchy(v(:),p.ampmodel.v_cauchy_beta,p.ampmodel.v_cauchy_sigma)) + .5*p.ampmodel.v_lambda_S*sum(sum(Slow(v)));
end
E= loga_noise_cost + v_cost;
E = double(E);

if nargout>1

    dv = - p.ampmodel.loga_noise_factor*(m.B'*loga_error);
    switch p.ampmodel.prior
        case 'laplace'
            dv = dv + dS_laplace(v,p.ampmodel.v_laplace_beta);
        case 'cauchy'
            dv = dv + dS_cauchy(v,p.ampmodel.v_cauchy_beta,p.ampmodel.v_cauchy_sigma);
        case 'slow_laplace'
            dv = dv + dS_laplace(v,p.ampmodel.v_laplace_beta) + p.ampmodel.v_lambda_S*Slowp(v);
        case 'slow_cauchy'
            dv = dv + dS_cauchy(v,p.ampmodel.v_cauchy_beta,p.ampmodel.v_cauchy_sigma)  + p.ampmodel.v_lambda_S*Slowp(v);
    end
    %dw(:,1) = 0;
    g = reshape(dv,numel(dv),1);
end
