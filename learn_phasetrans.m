% learn phasetrans D
%

% track the variance of w
var_eta=.1;
w_var=.1*ones(m.L,1);

if p.use_gpu
    m.D = gsingle(m.D);
end

for trial = 1:num_trials

    exit_flag=0;
    while ~exit_flag
        [dtphase, avalind] = crop_dtphase(Z_store,m,p);
        
        if p.use_gpu
            dtphase = gsingle(dtphase);
            avalind = gsingle(avalind);
        end
        % calculate coefficients for these data via gradient descent
        [w dtphase_E exit_flag]=infer_w(dtphase,avalind,m,p);
        %if ~exit_flag
        %    p.phasetrans.eta_w = .8*p.phasetrans.eta_w;
        %else
        %    p.phasetrans.eta_w = 1.01*p.phasetrans.eta_w;
        %end

    end
    [m,p] = adapt_phasetrans(w,dtphase_E,m,p);
    
    % display
    if (mod(m.t,display_every)==0)
        % Track some statistics of the inferred variables
        w_var = (1-var_eta)*w_var + var_eta*mean(abs(w).^2,2);
        display_Dquick(m,w_var,11);
        %display_D(m,13);
    end
    
    % save some memory (GPU)
    clear w dtphase avalind
    
    % save
    if (mod(m.t,save_every)==0)
        save_model(sprintf(fname,sprintf('progress_t=%d',m.t)),m,p);
    end
    m.t=m.t+1;
    if (mod(m.t,100)==0)
        fprintf('\n%d',m.t)
    end
    fprintf('\n')
end
