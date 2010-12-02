function [m,p] = adapt_ampmodel(v,loga,loga_E,m,p)

sz = size(v,2);
switch p.ampmodel.basis_method
    case 'steepest'
        dB = loga_E*v';
        eta_dB = p.ampmodel.B_eta*dB/sz;
        m.B = m.B+eta_dB;
        
        fprintf('\r\n mean(dB)=%6.6f, max(dB)=%6.6f, var(dB)=%6.6f \r \n',double(mean(abs(eta_dB(:)))), double(max(abs(eta_dB(:)))), double(var(eta_dB(:))));
        
    case 'steepest_adapt'
        dB = loga_E*v';
        eta_dB = p.ampmodel.B_eta*dB/sz;
        m.B = m.B+eta_dB;
        
        if max(abs(eta_dB(:))) > p.ampmodel.eta_dB_target
            p.ampmodel.B_eta = p.ampmodel.B_eta*p.ampmodel.down_factor;
            fprintf('\neta_dB(:) above target, decreasing... to B_eta=%f',p.ampmodel.B_eta)
        else
            p.ampmodel.B_eta = p.ampmodel.B_eta*p.ampmodel.up_factor;
        end
        
        fprintf('\r\n mean(dB)=%6.6f, max(dB)=%6.6f, var(dB)=%6.6f \r \n',double(mean(abs(eta_dB(:)))), double(max(abs(eta_dB(:)))), double(var(eta_dB(:))));

    case 'minFunc_ind_wd'        
        B = reshape(m.B,numel(m.B),1);
        E0 = obj_fun_B(B,loga,v,m,p);
        [B, E, ~] = minFunc_ind(@obj_fun_B,B,p.ampmodel.B_minFunc_ind_Opts,loga,v,m,p);
        m.B = reshape(B,m.N,m.K);
        
        fprintf('\r\n oldE = %2.2e newE = %2.2E \r \n',E0,E)
        
    otherwise
        disp('WARNING, UNKOWN ampmodel.basis_method')
end

if p.renorm_length
    % Keep our BFs from expanding; adapt magnitude
    normB = sqrt(sum(m.B.^2));
    m.B = m.B*diag(1./normB');
end