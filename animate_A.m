% animate_A.m - animate set of complex bfs
%
% function mov = animate_A(A)

function [mov] = animate_A(m,fig_num,repeats,whiten)

if ~exist('repeats','var')  
    repeats=1;
end

if ~exist('whiten','var')
    whiten = 0;
end

A = double(m.A);
if isfield(m,'dewhitenMatrix')
    if whiten
        A = m.zerophaseMatrix*m.dewhitenMatrix*bsxfun(@times,m.I_noise_factors,m.A);
    else
        A = m.dewhitenMatrix*A;
        %A = m.zerophaseMatrix*A;
    end
end

[L M]=size(A);

sz=sqrt(L);
phi_step = 2*pi/64;
phi=0:phi_step:2*pi-phi_step;
nphi=length(phi);

clim=max(abs(A));

buf=1;

if floor(sqrt(M))^2 ~= M
  m=sqrt(M/2);
  n=M/m;
else
  m=sqrt(M);
  n=m;
end

sfigure(fig_num)
clf()
array=-ones(buf+m*(sz+buf),buf+n*(sz+buf));
h=imagesc(array,'EraseMode','none',[-1 1]);
axis image off
colormap gray

mov=zeros([size(array) nphi]);
for i=1:nphi

    An=real(exp(-1j*phi(i))*A)*diag(1./clim);
    
    k=1;
    for c=1:n
        for r=1:m
            array(buf+(r-1)*(sz+buf)+[1:sz],buf+(c-1)*(sz+buf)+[1:sz])=...
                reshape(An(:,k),sz,sz);
            k=k+1;
        end
    end
    mov(:,:,i)=array;
end

for i=1:nphi*repeats
    ind = mod(i,nphi) + 1;
    set(h,'CData',mov(:,:,ind));
    axis off
    drawnow   
end