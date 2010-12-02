function save_model(fname,m,p)

% Ahist=cat(3,Ahist,A); % Save a history of A?
fprintf(['\nWriting file: ' fname '...']);
if p.use_gpu
    m.A = double(m.A);
    m.D = double(m.D);
end
eval(['save state/' fname ' m p']);
fprintf(' Done.\n');
