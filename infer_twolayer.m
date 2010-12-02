function [Z w v Ierror dtphase_error loga_error exit_flag]= infer_twolayer(I,m,p)

% infer feedforward first
[Z Ierror ~]= infer_Z(I,m,p);
a = abs(Z);
phase = angle(Z);
[dtphase,avalind] = calc_dtphase(a,phase,m,p);
[loga] = calc_logamp(a,m,p);
[w dtphase_error ~] = infer_w(dtphase,avalind,m,p);
[v loga_error ~] = infer_v(loga,m,p);

% infer joint model
switch p.twolayer.inference_method
    
    case 'minFunc_ind'
        a = abs(Z);
        phase = angle(Z);
        X0 = [reshape(a,numel(a),1); reshape(phase,numel(phase),1); reshape(w,numel(w),1); reshape(v,numel(v),1)];
        [E, ~, ~, Ierror] = obj_fun_twolayer(X0,I,m,p);
        SNR = -10*log10(var(Ierror(:))/var(I(:)));
        fprintf('\rtwolayer: E=%02.4e, SNR=%2.2f',double(E),double(SNR));
        
        %check('obj_fun_twolayer',X0,0.000001, I,m,p)
        
        [X, E, ~] = minFunc_ind(@obj_fun_twolayer,X0,p.twolayer.minFunc_ind_Opts,I,m,p);
        sz = size(I,2);
        astop = sz*m.N;
        a = reshape(X(1:astop),m.N,sz);
        phase = reshape(X(astop+1:2*astop),m.N,sz);
        Z = a.*exp(1j*phase);
        wstop = sz*m.L;
        w0 = X(2*astop+1:2*astop+wstop);
        w = reshape(w0,m.L,sz);
        vstop = sz*m.K;
        v0 = X(2*astop+wstop+1:2*astop+wstop+vstop);
        v = reshape(v0,m.K,sz);

        [Ierror, Ih] = calc_Ierror(I,a,phase,m,p);
        
        SNR = -10*log10(var(Ierror(:))/var(I(:)));
        fprintf('\rtwolayer: E=%02.4e, SNR=%2.2f\r',double(E),double(SNR));

        if p.show_p
            [dtphase,avalind] = calc_dtphase(a,phase,m,p);
            [loga] = calc_logamp(a,m,p);

            [dtphase_error, dtphase_hat] = calc_dtphase_error(dtphase,avalind,w,m,p);            
            [loga_error, loga_hat] = calc_loga_error(loga,v,m,p);
            
            display_infer_twolayer(a,phase,I,Ih,dtphase,dtphase_hat,avalind,w,loga,loga_hat,v,m,p);
            pause(.5)
        end
        
        exit_flag = 1;
end

function display_infer_twolayer(a,phase,I,Ih,dtphase,dtphase_hat,avalind,w,loga,loga_hat,v,m,p)
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
