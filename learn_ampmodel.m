% learn ampmodel B
%

% track the variance of v
var_eta=.1;
v_var=.1*ones(m.K,1);

if p.use_gpu
    m.B = gsingle(m.B);
end

for trial = 1:num_trials

    exit_flag=0;
    while ~exit_flag
        [loga] = crop_rand_logamp(Z_store,m,p);
        
        if p.use_gpu
            loga = gsingle(loga);
        end
        % calculate coefficients for these data via gradient descent
        [v loga_E exit_flag]=infer_v(loga,m,p);
        %if ~exit_flag
        %    p.ampmodel.eta_v = .8*p.ampmodel.eta_v;
        %else
        %    p.ampmodel.eta_v = 1.01*p.ampmodel.eta_v;
        %end
        
    end
    [m,p] = adapt_ampmodel(v,loga,loga_E,m,p);
    
    % display
    if (mod(m.t,display_every)==0)
        % Track some statistics of the inferred variables
        v_var = (1-var_eta)*v_var + var_eta*mean(abs(v).^2,2);
        display_Bquick(m,v_var,21);
        %display_B(m,23);
    end
    
    % save some memory (GPU)
    clear v loga
    
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
