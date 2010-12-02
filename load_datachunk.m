function chunk = load_datachunk(m,p)

rind = ceil(rand*(p.num_chunks-p.cons_chunks));
chunk = load_movie(rind,p.cons_chunks,p.imszt,p.data_root,p.imsz);


function [F] = load_movie(startchunk, numchunks, chunklength_t, D,imsz)

if ~exist('imsz','var')
    imsz = 128;
end

F = zeros(imsz,imsz,chunklength_t*numchunks);

for i=1:numchunks,
  s_idx = (chunklength_t*(i-1))+1;
  f_idx = chunklength_t*i;
  F(:,:,s_idx:f_idx) = ...
    read_chunk(D,i+startchunk-1,imsz,chunklength_t); 
end

function F = read_chunk(dataroot,i,imsz,imszt)
% read_chunk.m - function to read a movie chunk
%
% function F = read_chunk(dataroot,i,imsz,imszt)

filename=sprintf('%s/chunk%d',dataroot,i);
fprintf('%s\n',filename);
fid=fopen(filename,'r','b');
F=reshape(fread(fid,imsz*imsz*imszt,'float'),imsz,imsz,imszt);
fclose(fid);