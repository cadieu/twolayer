function [E, g, dtphase_hat, dtphase_error] = obj_fun_w(X,dtphase,avalind,m,p)

sz = size(dtphase,2);
w = reshape(X,m.L,sz);

[dtphase_error, dtphase_hat] = calc_dtphase_error(dtphase,avalind,w,m,p);

% Compute Energy Terms
phase_slowness = p.phasetrans.phase_noise_factor*sum(1 - cos(dtphase_error(:)));
switch p.phasetrans.prior
    case 'slow_laplace'
        w_cost  = sum(S_laplace(w(:),p.phasetrans.w_laplace_beta)) + .5*p.phasetrans.w_lambda_S*sum(sum(Slow(w)));
    case 'slow_cauchy'
        w_cost  = sum(S_cauchy(w(:),p.phasetrans.w_cauchy_beta,p.phasetrans.w_cauchy_sigma)) + .5*p.phasetrans.w_lambda_S*sum(sum(Slow(w)));
end
E= phase_slowness + w_cost;
E = double(E);
if nargout>1

    %     mse,a_sparsity,a_slowness,phase_slowness,w_sparsity,f_eval);
    switch p.phasetrans.prior
        case 'slow_laplace'
            dw = -p.phasetrans.phase_noise_factor*(m.D.'*(sin(dtphase_error))) + dS_laplace(w,p.phasetrans.w_laplace_beta) + p.phasetrans.w_lambda_S*Slowp(w);
        case 'slow_cauchy'
            dw = -p.phasetrans.phase_noise_factor*(m.D.'*(sin(dtphase_error))) + dS_cauchy(w,p.phasetrans.w_cauchy_beta,p.phasetrans.w_cauchy_sigma) + p.phasetrans.w_lambda_S*Slowp(w);
    end
    %dw(:,1) = 0;
    g = reshape(dw,numel(dw),1);
end
