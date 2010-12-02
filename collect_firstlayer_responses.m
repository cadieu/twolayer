
if p.use_gpu
    m.A = gsingle(m.A);
end

p.segment_szt = p.imszt*p.cons_chunks;
Z_store = zeros(m.N,p.segment_szt*p.load_segments,'single');
s_count = 1;
for segment = 1:p.load_segments

    if mod(segment,p.patches_load) == 1
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
    
    Z_store(:,(s_count-1)*p.segment_szt+1:s_count*p.segment_szt) = Z;
    s_count = s_count + 1;
end
