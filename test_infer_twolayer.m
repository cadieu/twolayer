load state/patchsz20_A269x400_D256_B256_6_secondlayer_prelearn_phasetrans_t=230001.mat
load data/patchsz20_A269x400_D256_B256_6_secondlayer_Z_responses.mat Z_store

warning('off','MATLAB:divideByZero')
warning('off','MATLAB:nearlySingularMatrix')
%%
F = load_datachunk(m,p);
X = crop_chunk(F,m,p);
%X = X(:,1:4);

%%
p.firstlayer.prior = 'slow_gauss';
p.firstlayer.a_gauss_beta = 8.;

p.twolayer.inference_method = 'minFunc_ind';
p.twolayer.minFunc_ind_Opts.Method = 'csd';%'csd';%'csd';%'bb';%'cg';%'lbfgs';
p.twolayer.minFunc_ind_Opts.Display = 'final';
p.twolayer.minFunc_ind_Opts.MaxIter = 150;
p.twolayer.minFunc_ind_Opts.MaxFunEvals = 300;

p.twolayer.phasetrans_feedback_factor = .1; % .1
p.twolayer.ampmodel_feedback_factor = 1.;   % 1

p.show_p = 1;

[Z w v I_E dtphase_E loga_E exit_flag]=infer_twolayer(X,m,p);

%%
figure(101);
subplot(141);
hist(log(abs(Z(:))),101);
title('loga')
subplot(142)
hist(real(Z(:)),101);
title('real(Z)')
subplot(143);
hist(w(:),101);
title('w')
subplot(144)
hist(v(:),101);
title('v')