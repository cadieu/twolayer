function [E, g] = obj_fun_B(X,loga,v,m,p)

batch_size = size(loga,2);
B = reshape(X,m.N,m.K);

loga_hat = B*v;

loga_error = loga-loga_hat;

% compute the energy
E = .5*sum(loga_error(:).^2)/batch_size + 0.5*p.ampmodel.B_gamma*sum(B(:).^2);

% compute the gradient
if nargout > 1
    dB = -loga_error*v'/batch_size + p.ampmodel.B_gamma*B;
    g = reshape(dB,numel(dB),1);

end
