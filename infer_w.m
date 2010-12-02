function [w dtphase_error exit_flag] = infer_w(dtphase,avalind,m,p)
% infer_w.m - infer w phasetrans variables from first layer responses
%
% function [w dtphase_E exit_flag] = infer_w(dtphase,avalind,m,p)


% Setup parameters for the specified method
switch p.phasetrans.inference_method

    case 'steepest'
        szt = size(dtphase,2);
        w = .01*m.D'*(dtphase.*avalind);
        
        w0 = reshape(w,numel(w),1);
        [E0, ~, ~, ~] = obj_fun_w(w0,dtphase,avalind,m,p);

        exit_flag=1;
        for t=1:p.phasetrans.iter
            
            w0 = reshape(w,numel(w),1);
            [E, dw, dtphase_hat, ~] = obj_fun_w(w0,dtphase,avalind,m,p);
            dw = reshape(dw,m.L,szt);
            
            %dE=(E0-E)/E0;
            %if (dE< -.01) && (t>10)
            %    exit_flag=0;
            %    fprintf('\rInference unstable... exiting')
            %    break
            %elseif (dE<.00001) && (t>(.5*p.phasetrans.iter))
            %    exit_flag=1;
            %    fprintf('\rConverged at inter #: %1i',t)
            %    break
            %end
            %E0=E;
            
            w = w-p.phasetrans.eta_w*dw;
            
            % Compute measures
            if ~p.quiet && (p.p_every || (t==1 || t==p.phasetrans.iter) || p.show_p)
                                
                % Check for convergence
                max_dw     = p.phasetrans.eta_w*max(abs(dw(:)));

                fprintf('\rE=%6.0f, E0=%6.0f, dE=%6.0f, dw=%6.4f',...
                    double(E),double(E0),double(E-E0),double(max_dw));
                if p.show_p
                    display_infer_w(dtphase,dtphase_hat,avalind,w,m,p)
                end
            end
        end
        
        [dtphase_error, ~] = calc_dtphase_error(dtphase,avalind,w,m,p);
        
    case {'minFunc_ind','minFunc_ind_lbfgs'}

        szt = size(dtphase,2);
        w = .001*m.D'*(dtphase.*avalind);
        w = reshape(w,numel(w),1);
        
        [E, ~, ~, dtphase_error] = obj_fun_w(w,dtphase,avalind,m,p);
        SNR = -10*log10(var(1-cos(dtphase_error(:)))/var(1-cos(avalind(:).*dtphase(:))));
        fprintf('\rE=%02.4e, SNR=%2.2f',double(E),double(SNR));

        [w, E, ~] = minFunc_ind(@obj_fun_w,w,p.phasetrans.minFunc_ind_Opts,dtphase,avalind,m,p);
        w = reshape(w,m.L,szt);

        [dtphase_error, dtphase_hat] = calc_dtphase_error(dtphase,avalind,w,m,p);

        SNR = -10*log10(var(1-cos(dtphase_error(:)))/var(1-cos(avalind(:).*dtphase(:))));
        fprintf('\rE=%02.4e, SNR=%2.2f\r\n',double(E),double(SNR));
        
        if p.show_p
            display_infer_w(dtphase,dtphase_hat,avalind,w,m,p)
        end
        
        exit_flag=1;
        

end

fprintf('.')
function display_infer_w(dtphase,dtphase_hat,avalind,w,m,p)

dtphase_hat = dtphase_hat + -2*pi*sign(dtphase_hat).*round(abs(dtphase_hat)./(2*pi));

sfigure(15);
subplot(1,3,1)
imagesc(dtphase,[-1 1]*pi), axis off, colormap hsv
alpha(double(avalind));
freezeColors
title('dtphase')

subplot(1,3,2)
imagesc(dtphase_hat,[-1 1]*pi), axis off, colormap hsv
alpha(double(avalind));
freezeColors
title('dtphase_hat')

subplot(1,3,3)
hval = max(abs(w(:)));
imagesc(w,[-1 1]*hval), axis off, colormap gray
freezeColors
title('w')

drawnow;
