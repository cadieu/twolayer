function [Z Ierror exit_flag]= infer_Z(I,m,p)
% infer_Z.m - infer firstlayer latent variables
%
% function [Z Ierror exit_flag]= infer_Z(I,m,p)

% Setup parameters for the specified method
switch p.firstlayer.inference_method
    
    case 'steepest'

        sz = size(I,2);
        
        % Initialize the latent variables
        if p.use_gpu
            Z = .2*complex(grandn(m.N,sz),grandn(m.N,sz));
        else
            Z = .2*complex(randn(m.N,sz),randn(m.N,sz));
        end
        a = abs(Z);
        phase = angle(Z);

        aphase0 = [reshape(a,numel(a),1); reshape(phase,numel(phase),1)];
        [E0, ~, ~, ~] = obj_fun_z(aphase0,I,m,p);
        % Generative image model
        %Ih = real(A*conj(Z));

        exit_flag=1;
        for t=1:p.firstlayer.iter

            astop = sz*m.N;
            aphase0 = [reshape(a,numel(a),1); reshape(phase,numel(phase),1)];
            [E, daphase, Ih, Ierror] = obj_fun_z(aphase0,I,m,p);
            da = reshape(daphase(1:astop),m.N,sz);
            dphase = reshape(daphase((astop+1):2*astop),m.N,sz);

            dE=(E0-E)/E0;
            if (dE< -.01) && (t>10)
                exit_flag=0;
                fprintf('\rInference unstable... exiting')
                break
            elseif (dE<.00001) && (t>(.5*p.firstlayer.iter))
                exit_flag=1;
                fprintf('\rConverged at inter #: %1i',t)
                break
            end
            E0=E;
            
            % Update a, phase
            a     = a-p.firstlayer.eta_a*da;
            phase = phase-p.firstlayer.eta_phase*dphase;
            
            % deal with negative a
            anegind=a<=0;
            a(anegind)=0;
            
            %phase(anegind)=angle(Zr(anegind));%(rand(sum(anegind(:)),1)*2-1)*pi;%phase(anegind)+pi/10;
            
            Zr_real = real(m.A).'*Ierror;
            Zr_imag = imag(m.A).'*Ierror;

            Zr = complex(Zr_real,Zr_imag);
            aneg_angle = angle(Zr);
            phase(anegind) = 0;
            phase = phase + anegind.*aneg_angle;

            % Compute measures
            if ~p.quiet && (p.p_every || (t==1 || t==p.firstlayer.iter) || p.show_p)

                mse = sum(sum(bsxfun(@times,0.5*m.I_noise_factors,Ierror.^2)));
                a_sparsity=sum(S_cauchy(a(:),p.firstlayer.a_cauchy_beta,p.firstlayer.a_cauchy_sigma));
                a_slowness = p.firstlayer.a_lambda_S*sum(sum(Slow(a)));
                
                energy_measure=mse+a_sparsity+a_slowness;

                SNR = -10*log10(var(Ierror(:))/var(I(:)));

                max_da     = p.firstlayer.eta_a*max(abs(da(:)));
                max_dphase = p.firstlayer.eta_phase*max(abs(dphase(:)));

                fprintf('\rSNR=%2.2f, mse=%6.0f, a_spars=%6.0f, a_slow=%6.0f, E=%06.4f, da=%6.4f, dphase=%6.4f',...
                    double(SNR),double(mse),double(a_sparsity),double(a_slowness),double(energy_measure),double(max_da),double(max_dphase));
                %                 whos mse a_sparsity a_slowness w_sparsity energy_measure norm_da norm_dphase norm_dw
                if p.show_p
                    display_infer_Z(a,phase,I,Ih,m,p)                    
                end
            end
        end
        
        fprintf('.\n')
        Z = a.*exp(1j*phase);

    case {'minFunc_ind','minFunc_ind_lbfgs'}

        sz = size(I,2);
        
        % Initialize the latent variables
        if p.use_gpu
            Z = .2*complex(grandn(m.N,sz),grandn(m.N,sz));
        else
            Z = .2*complex(randn(m.N,sz),randn(m.N,sz));
        end
        %Z = 0.*complex(randn(m.N,sz),randn(m.N,sz));
        a = abs(Z);
        phase = angle(Z);
        
        astop = sz*m.N;
        aphase0 = [reshape(a,numel(a),1); reshape(phase,numel(phase),1)];

        [E, ~, ~, Ierror] = obj_fun_z(aphase0,I,m,p);
        SNR = -10*log10(var(Ierror(:))/var(I(:)));        
        fprintf('\rE=%02.4e, SNR=%2.2f',double(E),double(SNR));
        
        [aphase, E, ~] = minFunc_ind(@obj_fun_z,aphase0,p.firstlayer.minFunc_ind_Opts,I,m,p);
        a = reshape(aphase(1:astop),m.N,sz);
        phase = reshape(aphase((astop+1):2*astop),m.N,sz);
        
        [Ierror, Ih] = calc_Ierror(I,a,phase,m,p);
        
        SNR = -10*log10(var(Ierror(:))/var(I(:)));
        fprintf('\rE=%02.4e, SNR=%2.2f\r\n',double(E),double(SNR));
        
        if p.show_p
            display_infer_Z(a,phase,I,Ih,m,p)
            pause(.1);
        end
        
        Z = a.*exp(1j*phase);
        exit_flag=1;
end

function display_infer_Z(a,phase,I,Ih,m,p)
Z = double(a.*exp(1j*phase));
a = abs(Z);
phase = angle(Z);
if p.whiten_patches
    I  = bsxfun(@plus,m.dewhitenMatrix*I, m.imageMean);
    Ih = bsxfun(@plus,m.dewhitenMatrix*Ih,m.imageMean);
end

phase = phase + -2*pi*sign(phase).*round(abs(phase)./(2*pi));

sfigure(5);
subplot(2,2,2);
hval=max(abs(a(:)));
imagesc(a,[0 1]*hval), axis off, colormap gray
title('a')
subplot(2,2,4);
imagesc(phase,[-pi pi]), axis off, colormap hsv
alpha(double(a/max(a(:))));
freezeColors
title('phase')

subplot(2,2,1);
Ival=max(abs(I(:)));
imagesc(I,[-1 1]*Ival), axis off, colormap gray
title('I')
subplot(2,2,3);
imagesc(Ih,[-1 1]*Ival), axis off, colormap gray
title('Ihat')
drawnow;
