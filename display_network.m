%  display_network.m -- displays the state of the network 
%
%  h=display_network(A,Z_var,h);
%
%  A = basis function matrix
%  Z_var = vector of coefficient variances
%

function h=display_network(A,Z_var,fig_num)

if ~exist('fig_num','var')
    fig_num=1;
end

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

array=-ones(buf+n*(sz+buf),buf+m*(sz+buf));

k=1;
for c=1:m
  for r=1:n
    clim=max(abs(A(:,k)));
    array(buf+(r-1)*(sz+buf)+[1:sz],buf+(c-1)*(sz+buf)+[1:sz])=...
	reshape(A(:,k),sz,sz)/clim;
    k=k+1;
  end
end

sfigure(fig_num);
h=imagesc(array,'EraseMode','none',[-1 1]);
axis image off
colormap gray;

if exist('Z_var','var') && ~isempty(Z_var) && (max(Z_var(:)) > 0)
  sfigure(fig_num+1);
  subplot(211)
  bar(double(Z_var)), axis([0 M+1 0 double(max(Z_var))])
  title('Z variance')
  subplot(212)
  normA=sqrt(sum(abs(A).^2));
  bar(double(normA)), axis([0 M+1 0 double(max(normA))])
  title('basis norm (L2)')
end

drawnow