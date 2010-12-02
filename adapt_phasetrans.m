function [m,p] = adapt_phasetrans(w,dtphase_E,m,p)

sz = size(w,2);
switch p.phasetrans.basis_method
    case 'steepest'
        dD = sin(dtphase_E)*w';
        eta_dD = p.phasetrans.D_eta*dD/sz;
        m.D = m.D+eta_dD;
        
    case 'steepest_adapt'
        dD = sin(dtphase_E)*w';
        eta_dD = p.phasetrans.D_eta*dD/sz;
        m.D = m.D+eta_dD;
        
        if max(abs(eta_dD(:))) > p.phasetrans.eta_dD_target
            p.phasetrans.D_eta = p.phasetrans.D_eta*p.phasetrans.down_factor;
            fprintf('\neta_dD(:) above target, decreasing... to D_eta=%f',p.phasetrans.D_eta)
        else
            p.phasetrans.D_eta = p.phasetrans.D_eta*p.phasetrans.up_factor;
        end
        
    otherwise
        disp('WARNING, UNKOWN phasetrans.basis_method')
        
end

if p.renorm_length
    % Keep our BFs from expanding; adapt magnitude of real and imaginary parts
    normD = sqrt(sum(m.D.^2));
    m.D = m.D*diag(1./normD');
end

fprintf('\r\n mean(dD)=%6.6f, max(dD)=%6.6f, var(dD)=%6.6f \r \n',double(mean(abs(eta_dD(:)))), double(max(abs(eta_dD(:)))), double(var(eta_dD(:))));
