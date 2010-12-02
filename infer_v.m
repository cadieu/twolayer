function [v loga_error exit_flag] = infer_v(loga,m,p)
% infer_v.m - infer v ampmodel variables from first layer responses
%
% function [v loga_error exit_flag] = infer_v(loga,m,p)

% Setup parameters for the specified method
switch p.ampmodel.inference_method

    case 'steepest'
        
        szt = size(loga,2);
        v = .01*m.B'*loga;

        v0 = reshape(v,numel(v),1);
        [E0, ~, ~, ~] = obj_fun_v(v0,loga,m,p);
        
        exit_flag=1;
        for t=1:p.ampmodel.iter
            
            v0 = reshape(v,numel(v),1);
            [E, dv, loga_hat, loga_error] = obj_fun_v(v0,loga,m,p);
            dv = reshape(dv,m.K,szt);
            
            %dE=(E0-E)/E0;
            %if (dE< -.01) && (t>10)
            %    exit_flag=0;
            %    fprintf('\rInference unstable... exiting')
            %    break
            %elseif (dE<.00001) && (t>(.5*p.ampmodel.iter))
            %    exit_flag=1;
            %    fprintf('\rConverged at inter #: %1i',t)
            %    break
            %end
            %E0=E;

            v = v-p.ampmodel.eta_v*dv;
            
            % Compute measures
            if ~p.quiet && (p.p_every || (t==1 || t==p.ampmodel.iter) || p.show_p)
                                
                % Check for convergence
                max_dv     = p.ampmodel.eta_v*max(abs(dv(:)));
                SNR = -10*log10(var(loga_error(:))/var(loga(:)));

                fprintf('\rSNR=%2.2f, E=%6.0f, E0=%6.0f, dE=%6.0f, dv=%6.4f',...
                    double(SNR),double(E),double(E0),double(E-E0),double(max_dv));
                if p.show_p
                    display_infer_v(loga,loga_hat,v,m,p);
                end
            end
        end
                
    case {'minFunc_ind','minFunc_ind_lbfgs'}

        szt = size(loga,2);
        v = .01*m.B'*loga;
        v = reshape(v,numel(v),1);
        
        [E, ~, ~, loga_error] = obj_fun_v(v,loga,m,p);
        SNR = -10*log10(var(loga_error(:))/var(loga(:)));
        fprintf('\rE=%02.4e, SNR=%2.2f',double(E),double(SNR));
        
        [v, E, ~] = minFunc_ind(@obj_fun_v,v,p.ampmodel.minFunc_ind_Opts,loga,m,p);
        v = reshape(v,m.K,szt);

        [loga_error, loga_hat] = calc_loga_error(loga,v,m,p);
        
        % Compute measures
        SNR = -10*log10(var(loga_error(:))/var(loga(:)));
        fprintf('\rE=%02.4e, SNR=%2.2f\r\n',double(E),double(SNR));

        if p.show_p
            display_infer_v(loga,loga_hat,v,m,p);
            pause(.5)
        end
        
        exit_flag=1;
        
    case {'thresholding','tc'}
        [loga_error, ~] = calc_loga_error(loga,zeros(m.K,size(loga,2)),m,p);

        fprintf('\rloga_error=%2.2e\r\n',sum(loga_error(:).^2));
        v = tc(double(m.B),double(loga),p.ampmodel.v_laplace_beta,p.ampmodel.tcparams.adapt,p.ampmodel.tcparams.eta,p.ampmodel.tcparams.num_iterations,p.ampmodel.tcparams.thresh_type);

        [loga_error, loga_hat] = calc_loga_error(loga,v,m,p);
        
        % Compute measures
        SNR = -10*log10(var(loga_error(:))/var(loga(:)));
        v_sparsity = sum(S_laplace(v(:),p.ampmodel.v_laplace_beta));
        fprintf('\rSNR=%2.2f, loga_error=%2.2e, v_spars=%2.2e\r\n',SNR,sum(loga_error(:).^2),v_sparsity);
        
        if p.show_p
            display_infer_v(loga,loga_hat,v,m,p);
            pause(.5)
        end
        
        exit_flag=1;
end

fprintf('.\n')

function display_infer_v(loga,loga_hat,v,m,p)

hval = max(loga(:));
lval = min(loga(:));
sfigure(26);
subplot(1,3,1)
imagesc(loga,[lval hval]), axis off, colormap gray
freezeColors
title('loga')

subplot(1,3,2)
imagesc(loga_hat,[lval hval]), axis off, colormap gray
freezeColors
title('loga_hat')

subplot(1,3,3)
hval = max(abs(v(:)));
imagesc(v,[-1 1]*hval), axis off, colormap gray
freezeColors
title('v')

drawnow;