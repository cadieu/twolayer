function [m,p] = adapt_firstlayer(Z,I_E,m,p)

sz = size(I_E,2);
switch p.firstlayer.basis_method

    case 'steepest'
        dA=calc_dA(Z,I_E,m,p);
        eta_dA = p.firstlayer.A_eta*dA/sz;
        m.A=m.A-eta_dA;

    case 'steepest_adapt'
        dA=calc_dA(Z,I_E,m,p);
        eta_dA = p.firstlayer.A_eta*dA/sz;
        m.A=m.A-eta_dA;
        if max(abs(eta_dA(:))) > p.firstlayer.eta_dA_target
            p.firstlayer.A_eta = p.firstlayer.A_eta*p.firstlayer.down_factor;
            fprintf('\neta_dA(:) above target, decreasing... to A_eta=%f',p.firstlayer.A_eta)
        else
            p.firstlayer.A_eta = p.firstlayer.A_eta*p.firstlayer.up_factor;
        end
        
    otherwise
        disp('WARNING, UNKOWN firstlayer.basis_method !!')
end

if p.firstlayer.use_GS
    % GS orthogonalization
    m.A=complex(real(m.A),...
                imag(m.A)-real(m.A)*diag(sum(real(m.A).*imag(m.A))./sum(real(m.A).^2)));
end
% switch real and imaginary to avoid bias in the learning (only on odd iterations for display purposes)
m.A = complex(imag(m.A),real(m.A));

if p.renorm_length
    % Keep our BFs from expanding; adapt magnitude of real and imaginary parts
    realnormA = sqrt(sum((real(m.A).^2)))';
    imagnormA = sqrt(sum((imag(m.A).^2)))';
    m.A=complex(real(m.A)*diag(1./realnormA'),imag(m.A)*diag(1./imagnormA'));
end

fprintf('\r\n mean(dA)=%6.6f, max(dA)=%6.6f\r \n',double(mean(abs(eta_dA(:)))), double(max(abs(eta_dA(:)))));
