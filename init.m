function [m,p] = init(m,p)

%% misc
m.t = 1;

%% init data %%

switch p.data_type
    case 'vid075-chunks'
        
        p.num_chunks = 56;
        p.cons_chunks=1; % consecutive chunks to take
        
        % size of each movie chunk
        p.imsz=128;
        p.imszt=64;
        
        p.BUFF=4;
        p.topmargin=15;
        
        p.patches_load = 20;
                
        p.data_root='data/vid075-chunks';

    case 'vid075-whiteframes'
        
        p.num_chunks = 56;
        p.cons_chunks=1; % consecutive chunks to take
        
        % size of each movie chunk
        p.imsz=128;
        p.imszt=64;
        
        p.BUFF=4;
        p.topmargin=15;
        
        p.patches_load = 20;
        
        p.data_root='data/vid075-whiteframes';

    case 'vid075-whitened'
        
        p.num_chunks = 56;
        p.cons_chunks=1; % consecutive chunks to take
        
        % size of each movie chunk
        p.imsz=128;
        p.imszt=64;
        
        p.BUFF=4;
        p.topmargin=15;
        
        p.patches_load = 20;
        
        p.data_root='data/vid075-whitened';

    case 'BBCmotion-whiteframes'
        p.num_chunks = 80;
        p.cons_chunks=1; % consecutive chunks to take
        
        % size of each movie chunk
        p.imsz=360;
        p.imszt=48;
        
        p.BUFF=4;
        p.topmargin=0;
        
        p.patches_load = 10;
        
        p.data_root='data/BBCmotion/whiteframes';

end


%% whitening params %%

if p.whiten_patches
    p.whitening.pixel_noise_fractional_variance = .01;
    p.whitening.pixel_noise_variance_cutoff_ratio = 1.25; % 1 + var(signal)/var(noise)
    p.whitening.X_noise_fraction = 8.;
    p.whitening.X_noise_var = .01;
    % run whitening
    p.whitening.whiten_num_patches = min(400*m.patch_sz^2,200000);%160000;
    [m, p] = learn_whitening(m,p);
end

%% init basis functions %%

m.A = init_complex(m.M,m.N);
m.D = init_real(m.N,m.L);
m.B = init_real(m.N,m.K);

%% first layer %%

p.firstlayer.use_GS = 1;
switch p.firstlayer.basis_method
    case 'steepest_adapt'
        p.firstlayer.A_eta=.0001;
        p.firstlayer.eta_dA_target = .05;
        p.firstlayer.up_factor = 1.02;
        p.firstlayer.down_factor = .95;
        
    case 'steepest'
        p.firstlayer.A_eta=.05;
end

switch p.firstlayer.prior
    case 'slow_cauchy'        
        % a
        p.firstlayer.a_cauchy_beta = 10; % 2.2
        p.firstlayer.a_cauchy_sigma = .4; % .1
        p.firstlayer.a_lambda_S=.5;
        p.firstlayer.a_thresh  = exp(-4);
        
end

switch p.firstlayer.inference_method
    case 'steepest'
        p.firstlayer.iter  =  120;
        p.firstlayer.eta_a     = .00005;
        p.firstlayer.eta_phase = .0005;
        p.firstlayer.natural_gradient = 1;
        
    case 'minFunc_ind'
        p.firstlayer.minFunc_ind_Opts.Method = 'bb';%'csd';%'bb';%'cg';%
        p.firstlayer.minFunc_ind_Opts.Display = 'off';
        p.firstlayer.minFunc_ind_Opts.MaxIter = 15;%30;
        p.firstlayer.minFunc_ind_Opts.MaxFunEvals = 20;%60;
        p.firstlayer.natural_gradient = 1;

end



%% ampmodel %%

switch p.ampmodel.basis_method
    case 'steepest'
        p.ampmodel.B_eta=.01;
    case 'steepest_adapt'
        p.ampmodel.B_eta=.01;
        p.ampmodel.eta_dB_target = .03;
        p.ampmodel.up_factor = 1.02;
        p.ampmodel.down_factor = .95;
    case 'minFunc_ind_wd'
        p.ampmodel.B_gamma = 0.01;
        p.ampmodel.B_minFunc_ind_Opts.Method = 'cg';
        p.ampmodel.B_minFunc_ind_Opts.Display = 'final';
        p.ampmodel.B_minFunc_ind_Opts.MaxIter = 100;
        p.ampmodel.B_minFunc_ind_Opts.MaxFunEvals = 300;

end

switch p.ampmodel.prior
    case 'laplace'
        % loga noise variance
        p.ampmodel.loga_noise_var=.2;
        p.ampmodel.loga_noise_factor = 1./p.ampmodel.loga_noise_var;
        % v
        p.ampmodel.v_laplace_beta=2;
    case 'cauchy'
        % loga noise variance
        p.ampmodel.loga_noise_var=.2;
        p.ampmodel.loga_noise_factor = 1./p.ampmodel.loga_noise_var;
        % v
        p.ampmodel.v_cauchy_beta=.1;
        p.ampmodel.v_cauchy_sigma=sqrt(.01);
    case 'slow_laplace'
        % loga noise variance
        p.ampmodel.loga_noise_var=.2;
        p.ampmodel.loga_noise_factor = 1./p.ampmodel.loga_noise_var;
        % v
        p.ampmodel.v_laplace_beta=2;
        p.ampmodel.v_lambda_S = 10;
    case 'slow_cauchy'
        % loga noise variance
        p.ampmodel.loga_noise_var=.2;
        p.ampmodel.loga_noise_factor = 1./p.ampmodel.loga_noise_var;
        % v
        p.ampmodel.v_cauchy_beta=.1;
        p.ampmodel.v_cauchy_sigma=.05;
        p.ampmodel.v_lambda_S = 10;
end

switch p.ampmodel.inference_method
    case 'thresholding'
        p.ampmodel.tcparams.adapt = 0.96;
        p.ampmodel.tcparams.eta = 0.1;
        p.ampmodel.tcparams.num_iterations = 150;
        p.ampmodel.tcparams.thresh_type = 1; % soft = 1, hard = 0
        
    case 'steepest'
        p.ampmodel.iter  =  50;
        p.ampmodel.eta_v     = .005;
  
    case 'minFunc_ind'
        p.ampmodel.minFunc_ind_Opts.Method = 'csd';%'csd';%'bb';%'cg';%
        p.ampmodel.minFunc_ind_Opts.Display = 'final';
        p.ampmodel.minFunc_ind_Opts.MaxIter = 15;%30;
        p.ampmodel.minFunc_ind_Opts.MaxFunEvals = 20;%60;

end


%% phasetrans %%

switch p.phasetrans.basis_method
    case 'steepest'
        p.phasetrans.D_eta=.01;

    case 'steepest_adapt'
        p.phasetrans.D_eta=.01;
        p.phasetrans.eta_dD_target = .03;
        p.phasetrans.up_factor = 1.02;
        p.phasetrans.down_factor = .95;

end

p.phasetrans.a_on_fraction = .25;

switch p.phasetrans.prior
    case 'slow_cauchy'
        % phase
        p.phasetrans.phase_noise_var=.25;
        p.phasetrans.phase_noise_factor=1./p.phasetrans.phase_noise_var;
        % w
        p.phasetrans.w_cauchy_beta=.5;
        p.phasetrans.w_cauchy_sigma=.2236;%sqrt(.5);
        p.phasetrans.w_lambda_S = 5.;
        
        % ignore dphase parameters
        p.phasetrans.a_thresh  = .2;
end

switch p.phasetrans.inference_method
    case 'steepest'
        p.phasetrans.iter  =  50;
        p.phasetrans.eta_w     = .02;

    case 'minFunc_ind'
        p.phasetrans.minFunc_ind_Opts.Method = 'csd';%'csd';%'bb';%'cg';%
        p.phasetrans.minFunc_ind_Opts.Display = 'final';
        p.phasetrans.minFunc_ind_Opts.MaxIter = 15;%30;
        p.phasetrans.minFunc_ind_Opts.MaxFunEvals = 20;%60;
        
end
