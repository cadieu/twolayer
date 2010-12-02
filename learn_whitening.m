function [m, p] = learn_whitening(m,p)
num_patches = p.whitening.whiten_num_patches;


%% setup
X = zeros(m.patch_sz^2,num_patches);


%% Collect some data

crops_per_chunk = 20;
sind = 1;
crop_ind = 1;
while sind < num_patches
    
    if mod(crop_ind,crops_per_chunk) == 1
        F = load_datachunk(m,p);
    end
    
    x = crop_chunk(F,m,p);
    crop_ind = crop_ind + 1;
    len_chunk = size(x,2);
    eind =sind+len_chunk-1;
    if eind > num_patches
        eind = num_patches;
        x = x(:,1:eind - sind + 1);
        len_chunk = size(x,2);
    end

    X(:,sind:eind) = x;
    sind = sind + len_chunk;
end


%% Subtract mean
m.imageMean = mean(X,2);
X = bsxfun(@minus,X,m.imageMean);

m.pixel_variance = var(X(:));
m.pixel_noise_variance = p.whitening.pixel_noise_fractional_variance*m.pixel_variance;

%% Whitening transform
C = X*X'/num_patches;
clear X
[E, D] = eig(C);
[~, sind] = sort(diag(D),'descend');
d = diag(D);
d = d(sind);
E = E(:,sind);
m.imageEigVals = diag(d);
m.imageEigVecs = E;

% determine cutoff:
variance_cutoff = p.whitening.pixel_noise_variance_cutoff_ratio*m.pixel_noise_variance;
m.M = sum(d>variance_cutoff); % number of valid dims
varX = d(1:m.M);

%factors = real((varX-m.pixel_noise_variance).^(-.5));
factors = real(varX.^(-.5));
E = E(:,1:m.M);
D = diag(factors);

m.I_noise_factors = ones(m.M,1);
rolloff_ind = sum(varX>variance_cutoff*p.whitening.X_noise_fraction);
m.I_noise_factors(rolloff_ind+1:end) = .5*(1+cos(linspace(0,pi,m.M-rolloff_ind)));
m.I_noise_factors = m.I_noise_factors/p.whitening.X_noise_var;
m.I_noise_vars = 1./m.I_noise_factors;

%m.I_noise_vars = p.whitening.X_noise_fraction + (varX.*factors.^2)./(1-varX.*factors.^2+eps);
%m.I_noise_vars = p.whitening.X_noise_fraction*varX.*factors.^2;
%m.I_noise_vars = varX.*factors.^2 - (1-p.whitening.X_noise_fraction);
%m.pixel_noise_variance./(real(varX) - m.pixel_noise_variance);
%m.I_noise_vars = reshape(m.I_noise_vars,[],1);
%m.I_noise_factors = 1./m.I_noise_vars;

%% whitening transform
m.whitenMatrix = D*E';
m.dewhitenMatrix = E*D^(-1);
m.zerophaseMatrix = E*D*E';

%%
if p.show_p
    sfigure(51)
    clf()
    subplot(131)
    plot(varX,'-b')
    hold on
    plot(m.pixel_noise_variance*factors.^2,'--g')
    plot(varX.*factors.^2,'-k')
    plot(m.pixel_noise_variance*ones(size(varX)),'--r')
    plot(m.pixel_variance*ones(size(varX)),'--b')
    plot(m.I_noise_vars,'-g')
    legend('Original Signal Variance', 'New Noise Variance','New Signal Variance','Noise Variance','Pixel Variance','Firstlayer Noise Variance')
    xlabel('eigen index')
    ylabel('variance')
    subplot(132)
    plot(m.I_noise_factors)
    hold on
    plot(sqrt(m.I_noise_factors))
    legend('I noise factors','sqrt(I noise factors)')
    xlabel('eigen index')
    ylabel('I_noise_factor')
    subplot(133)
    plot(varX.*factors.^2)
    hold on
    plot(m.I_noise_factors.*varX.*factors.^2,'r')
    title('equivalent spectrum')
end
