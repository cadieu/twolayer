clear

% check the gradients
% specify model dimensions
m.patch_sz = 3; % image patch size
m.N =       4;  % firstlayer basis functions
m.L =        2;  % phasetrans basis functions
m.K =        2;  % ampmodel basis functions

% specify priors
p.firstlayer.prior = 'slow_cauchy';
p.ampmodel.prior = 'laplace';
p.phasetrans.prior = 'slow_cauchy';

% specify outerloop learning method
p.firstlayer.basis_method = 'ij_GS_adapt';
p.ampmodel.basis_method = 'steepest';
p.phasetrans.basis_method = 'steepest';
p.amptrans.basis_method = 'steepest';

% specifiy inference methods
p.firstlayer.inference_method='steepest';%'minFunc_ind';%
p.ampmodel.inference_method='steepest';%'minFunc_ind';%
p.phasetrans.inference_method='steepest';%'minFunc_ind';%
p.twolayer.inference_method='minFunc_ind';%'minFunc_ind';%

% data
p.data_type = 'vid075-chunks';

% misc
p.use_gpu = 0;
p.renorm_length=1;
p.normalize_crop=0;
p.whiten_patches=1;
p.p_every = 0;
p.show_p = 0;
p.quiet = 0;

%% Init
[m, p] = init(m,p);
Z_store = complex(randn(m.N,1024),randn(m.N,1024));

[m, p] = init_phasetrans(Z_store,m,p);
[m, p] = init_ampmodel(Z_store,m,p);


%% setup 
F = load_datachunk(m,p);

I = crop_chunk(F,m,p);

if p.use_gpu
    I = gsingle(I);
end

I = I(:,1:5);

[M L] = size(m.A);
sz = size(I,2);

% Initialize the latent variables
Z = .2*complex(randn(m.N,sz),randn(m.N,sz));
a = abs(Z);
phase = angle(Z);


%% check dA
X0 = zeros(2*m.M*m.N,1);
check('obj_fun_A',X0, 0.01, I, a, phase, m, p)

X0 = randn(2*m.M*m.N,1);
check('obj_fun_A',X0, 0.01, I, a, phase, m, p)


%% check dZ
p.firstlayer.natural_gradient = 0;
X0 = zeros(2*numel(a),1);
check('obj_fun_z',X0, 0.001, I, m, p)

X0 = randn(2*numel(a),1);
check('obj_fun_z',X0, 0.001, I, m, p)

%% check dw
X0 = zeros(5*m.L,1);
check('obj_fun_w',X0, 0.00001, randn(m.N,5),rand(m.N,5)>.1, m, p)

X0 = randn(5*m.L,1);
check('obj_fun_w',X0, 0.00001, randn(m.N,5),rand(m.N,5)>.1, m, p)

%% check dv
X0 = zeros(5*m.K,1);
check('obj_fun_v',X0,0.00001, randn(m.N,5), m, p)

X0 = randn(5*m.K,1);
check('obj_fun_v',X0,0.00001, randn(m.N,5), m, p)

%% check twolayer

%m.I_noise_factors = zeros(size(m.I_noise_factors));
%m.I_noise_vars = Inf*ones(size(m.I_noise_vars));
%p.firstlayer.a_cauchy_beta = 0;
%p.firstlayer.a_lambda_S = 0;
%p.firstlayer.a_gauss_beta = 0;

p.firstlayer.natural_gradient = 0;
sz = 3;
X0 = zeros(sz*(2*m.N + m.L + m.K),1);
check('obj_fun_twolayer',X0,1e-6, randn(m.M,sz),m,p)

X0 = randn(sz*(2*m.N + m.L + m.K),1);
X0(1:2*m.N*sz) = abs(X0(1:2*m.N*sz)) + 10.;
check('obj_fun_twolayer',X0,1e-6, randn(m.M,sz),m,p)

