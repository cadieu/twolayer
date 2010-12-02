function display_secondlayer(D,model,fig,spacing)

if nargin < 3
    fig=1;
end

Acoords = model.Acoords;
if nargin < 4
    % rescale Acoords
    for i = 1:4
        Acoords(i,:) = Acoords(i,:) - min(Acoords(i,:));
        Acoords(i,:) = Acoords(i,:)/max(Acoords(i,:));
    end
    xyspace = 1.25;
    fxspace = 1.25;
else
    xyspace = spacing(1);
    fxspace = spacing(2);
end

spacing = .015;

[L M]=size(D);

if floor(sqrt(M))^2 ~= M
    m=ceil(sqrt(M/2));
    n=M/m;
else
    m=sqrt(M);
    n=m;
end

% Remove BF with very low spatial frequency (removes mean)
% v = sqrt(sum(Acoords(3:4,:).^2));
% inds = find(v>.07);
% D=D(inds,:); Acoords=Acoords(:,inds);

% array=-ones(buf+n*(sz+buf),buf+m*(sz+buf));
sfigure(fig);
clf
colormap(cjet)
sfigure(fig+1);
clf
colormap(cjet)

% plot x-y display
% xyspace = 27;
k=1;
xCoords = [];
yCoords = [];
Dvals = [];
for c=1:m
    for r=1:n
%         subp(m,n,c+(r-1)*n,spacing);
%         subplot(m,n,c+(r-1)*n)
        hval = max(abs(D(:,k)));
        [vals order] = sort(abs(D(:,k)),'descend');
        xCoords = [xCoords (Acoords(1,order)+c*xyspace)];
        yCoords = [yCoords (Acoords(2,order)-r*xyspace)];
        Dvals = [Dvals (D(order,k)./hval)'];
            
%         scatter(Acoords(1,order),Acoords(2,order),50,D(order,k),'filled'), axis square off
%         axis([0 21 0 21])
%         caxis([-1 1]*hval);
        k=k+1;
    end
end
sfigure(fig);
set(gcf,'Color','k')
set(gcf,'inverthardcopy','off')
subp(1,1,1,spacing);
scatter(xCoords,yCoords,50,Dvals,'filled'), axis equal off

% plot vx-vy display
% fxspace = 5;
k=1;
vxCoords = [];
vyCoords = [];
Dvals = [];
for c=1:m
    for r=1:n
%         subp(m,n,c+(r-1)*n,spacing);
%         subplot(m,n,c+(r-1)*n)
        hval = max(abs(D(:,k)));
        [vals order] = sort(abs(D(:,k)),'descend');
        vxCoords = [vxCoords (Acoords(3,order)+c*fxspace)];
        vyCoords = [vyCoords (Acoords(4,order)-r*fxspace)];
        Dvals = [Dvals (D(order,k)./hval)'];
       
        
%         scatter(Acoords(3,order),Acoords(4,order),50,D(order,k),'filled'), axis square off
%         axis([-1 1 -1 1]*2)
%         caxis([-1 1]*hval);
        k=k+1;
    end
end

sfigure(fig+1);
set(gcf,'Color','k')
set(gcf,'inverthardcopy','off')
subp(1,1,1,spacing);
scatter(vxCoords,vyCoords,50,Dvals,'filled'), axis equal off

% % plot quiver display
% xyspace = 27;
% k=1;
% xCoords = [];
% yCoords = [];
% vxCoords = [];
% vyCoords = [];
% Dvals = [];
% for c=1:m
%     for r=1:n
% %         subp(m,n,c+(r-1)*n,spacing);
% %         subplot(m,n,c+(r-1)*n)
%         hval = max(abs(D(:,k)));
%         [vals order] = sort(abs(D(:,k)),'descend');
%         Dvals = [Dvals (D(order,k)./hval)'];
%         vxCoords = [vxCoords (Acoords(3,order))];
%         vyCoords = [vyCoords (Acoords(4,order))];
%         xCoords = [xCoords (Acoords(1,order)+c*xyspace)];
%         yCoords = [yCoords (Acoords(2,order)-r*xyspace)];
%        
%         
% %         scatter(Acoords(3,order),Acoords(4,order),50,D(order,k),'filled'), axis square off
% %         axis([-1 1 -1 1]*2)
% %         caxis([-1 1]*hval);
%         k=k+1;
%     end
% end
% 
% sfigure(fig+2)
% clf
% subp(1,1,1,spacing);
% Magfact = 1;
% vMag = sqrt(vxCoords.^2 + vyCoords.^2)./Magfact;
% vScaling = 1./vMag.^2;
% quiver(xCoords,yCoords,vxCoords.*Dvals./vMag.^2,vyCoords.*Dvals./vMag.^2,0), axis square off


% if exist('h','var') && ~isempty(h)
%     set(h,'CData',array);
% else
%     h=imagesc(array,'EraseMode','none',[-1 1]);
%     axis image off
%     colormap gray; freezeColors
% end
% 
% if exist('Z_var','var') && ~isempty(Z_var)
%     sfigure(fig_num+1)
%     subplot(211)
%     bar(Z_var), axis([0 M+1 0 max(Z_var)])
%     title('Z variance')
%     subplot(212)
%     normA=sqrt(sum(abs(A).^2));
%     bar(normA), axis([0 M+1 0 max(normA)])
%     title('basis norm (L2)')
% end

drawnow
