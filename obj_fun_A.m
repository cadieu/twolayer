function [E, g] = obj_fun_A(X,I,a,phase,m,p)
Astop = m.M*m.N;
Areal = reshape(X(1:Astop),m.M,m.N);
Aimag = reshape(X((Astop+1):end),m.M,m.N);
A = complex(Areal,Aimag);

Ihat = real(A)*(a.*cos(phase)) + imag(A)*(a.*sin(phase));%real(Phi(:,:,t)*conj(Z));

Ierror = I - Ihat;

% Compute Energy Terms
switch p.firstlayer.prior
    case 'slow_cauchy'
        mse = sum(sum(bsxfun(@times,0.5*m.I_noise_factors,Ierror.^2)));
        E = mse;
end

if nargout > 1
    Z = a.*exp(1j*phase);
    dA = calc_dA(Z,Ierror,m,p);
    
    g = [reshape(real(dA),numel(dA),1); reshape(imag(dA),numel(dA),1)];

end
