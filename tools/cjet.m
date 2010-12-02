function cmap = cjet(N)
% returns a custom colormap, N by 3;
if nargin < 1,
  N = 256;
end;

if 1, % jet with grey in middle
  c = repmat((1-exp(-abs(((1:N)-(N+1)/2)/40).^2))',1,3); 
  c = (c - min(c(:))); c = c/max(c(:));
  cmap = (1-c).*gray(N) + c.*jet(N);  

else, % red - blue
  a = linspace(1,0,256)';
  b = linspace(0, .5, 128)'; b = [b;b(end:-1:1)];
  cmap = [a(end:-1:1), b, a];
end;