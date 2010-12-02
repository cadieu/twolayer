function h = subp(nr,nc,j, spacing)
% function h = subp(nr,nc,j, spacing)

if nargin < 4,
  spacing = .04;
end;

sizex = 1/nc - spacing;
sizey = 1/nr - spacing;

startx = spacing/2 + 1/nc*rem(j-1,nc);      
starty = 1 + spacing/2 - 1/nr - 1/nr*floor((j-1)/nc);  

posax = [startx, starty, sizex, sizey];

h = axes('pos',posax);