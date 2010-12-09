%  display_network.m -- displays the state of the network 
%  (complex bfs and output variances)
%
%  h=display_network(A,Z_var,h);
%
%  A = complex basis function matrix
%  Z_var = vector of coefficient variances
%

function [array] =display_A(m,Z_var,fig_num)

if ~exist('fig_num','var')
    fig_num=1;
end

A = double(m.A);
if isfield(m,'dewhitenMatrix')
    A = m.dewhitenMatrix*A;
    array = display_Ahelper(A,fig_num);
    A = m.zerophaseMatrix*A;
    display_Ahelper(A,fig_num+1);
else
    array = display_Ahelper(A,fig_num);
end

if exist('Z_var','var')  && ~isempty(Z_var) && (max(Z_var(:)) > 0)
  sfigure(fig_num+2);
  subplot(211)
  bar(double(Z_var)), axis([0 m.M+1 0 double(max(Z_var))])
  title('Z variance')
  subplot(212)
  normA=sqrt(sum(abs(m.A).^2));
  bar(double(normA)), axis([0 m.M+1 0 double(max(normA))])
  title('basis norm (L2)')
end

drawnow

function array = display_Ahelper(A,fig_num)

[L M]=size(A);
sz=sqrt(L);

buf=1;

if floor(sqrt(M))^2 ~= M
  m=sqrt(M/2);
  n=M/m;
else
  m=sqrt(M);
  n=m;
end

array=-ones(buf+n*(sz+buf),buf+m*(sz+buf))*(1+1j);
k=1;
for c=1:m
  for r=1:n
    clim=max(abs(A(:,k)));
    array(buf+(r-1)*(sz+buf)+[1:sz],buf+(c-1)*(sz+buf)+[1:sz])=...
	reshape(A(:,k),sz,sz)/clim;
    k=k+1;
  end
end

% if exist('h','var') && ~isempty(h)
%   subplot(221)
%   set(h(1),'CData',real(array));
%   axis image off
%   colormap gray; freezeColors
%   subplot(222)
%   set(h(2),'CData',imag(array));
%   axis image off
%   colormap gray; freezeColors
%   subplot(223)
%   set(h(3),'CData',abs(array));
%   axis image off
%   colormap gray; freezeColors
%   subplot(224)
%   set(h(4),'CData',angle(array));
%   alpha(abs(array)/max(abs(array(:))));
%   axis image off
%   colormap hsv; freezeColors
% else
subp_space = 0.03;
sfigure(fig_num);
clf;
%title('First-layer complex basis functions (m.A)')
colormap gray
subp(2,2,1,subp_space);
h(1)=imagesc(real(array),[-1 1]);
axis image off
colormap gray; freezeColors
title('real')
subp(2,2,2,subp_space);
h(2)=imagesc(imag(array),[-1 1]);
axis image off
colormap gray; freezeColors
title('imag')
subp(2,2,3,subp_space);
h(3)=imagesc(abs(array),[0 max(abs(array(:)))]);
axis image off
title('abs')
colormap gray; freezeColors
subp(2,2,4,subp_space);
h(4)=imagesc(angle(array),[-pi pi]);
alpha(abs(array)/max(abs(array(:))));
axis image off
colormap hsv; freezeColors
title('angle')
% end
