% learn the firstlayer A's
%

% track the variance of a
var_eta=.1;
Z_var=.1*ones(m.N,1);

if display_every
    display_A(m,Z_var,1);
end

if p.use_gpu
    m.A = gsingle(m.A);
end

for trial = 1:num_trials

    if mod(trial,p.patches_load) == 1
        F = load_datachunk(m,p);
    end

    exit_flag=0;
    while ~exit_flag
        X = crop_chunk(F,m,p);
        
        if p.use_gpu
            X = gsingle(X);
        end
        % calculate coefficients for these data via gradient descent
        [Z I_E exit_flag]=infer_Z(X,m,p);        

    end
    [m,p] = adapt_firstlayer(Z,I_E,m,p);
    
    % display
    if (mod(m.t,display_every)==1)
        % Track some statistics of the inferred variables
        Z_var = (1-var_eta)*Z_var + var_eta*mean(abs(Z).^2,2);
        display_A(m,Z_var,1);
    end
    
    % save some memory (GPU)
    clear Z I_E
    
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
