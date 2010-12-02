function m = fit_Acoords(m)
% Find the x, y position, and fx, fy, frequency parameters for the CBFs

center_method = 'cm'; % 'max';%

A = double(m.A);
% remove mean:
%A(1,:) = 0;
if isfield(m,'dewhitenMatrix')
    A = m.zerophaseMatrix*m.dewhitenMatrix*A;
end
A = bsxfun(@minus,A,mean(A,1));

[L M] = size(A);
sz = sqrt(L);

if license('checkout','Image_Toolbox')
    imresize_handle = @imresize;
    up = 4*sz;
else
    imresize_handle = @pass_imresize;
    up = sz;
end

im_space = linspace(1,sz,up);
[xspace yspace] = meshgrid(im_space);
yspace = flipud(yspace);
[fxspace fyspace] = meshgrid([-up/2:(up/2-1)]*2*pi/up);
fyspace = flipud(fyspace);
% fyspace = ifftshift(fyspace);
% fxspace = ifftshift(fxspace);
% fq_space = [-up/2:(up/2-1)]*2*pi/up;
Acoords = zeros(4,M);
for i=1:M
    Aim = reshape(A(:,i),sz,sz);
    AF = fftshift(fft2(Aim));
    
    aAim= imresize_handle(abs(Aim),[up up]);
    aAF = imresize_handle(abs(AF),[up up]);
    switch center_method
        case 'max'
            % Compute centers using max index
            Acoords(1,i) = xspace(aAim==max(aAim(:)));
            Acoords(2,i) = yspace(aAim==max(aAim(:)));
            Acoords(3,i) = fxspace(aAF==max(aAF(:)));
            Acoords(4,i) = fyspace(aAF==max(aAF(:)));
        case 'cm'
            % Compute centers using average
            xw = sum(abs(Aim));
            yw = sum(abs(Aim),2);
            fxw = sum(abs(aAF));
            fyw = sum(abs(aAF),2);
            Acoords(1,i) = sum(im_space.*xw)./sum(xw);
            Acoords(2,i) = sum(flipud(im_space').*yw)./sum(yw);
            Acoords(3,i) = sum(fxspace(1,:).*fxw)./sum(fxw);
            Acoords(4,i) = sum(fyspace(:,1).*fyw)./sum(fyw);
    end
    if 0
        figure(2)
        subplot(131)
        imagesc(real(Aim)), colormap gray, axis image
        subplot(132)
        hold off
        imagesc(xspace(1,:), yspace(:,1)',abs(Aim)), colormap gray, axis image
        hold on
        scatter(Acoords(1,i),Acoords(2,i));
        subplot(133)
        hold off
        imagesc(fxspace(1,:),fyspace(:,1)',abs(AF)), colormap gray, axis image
        hold on
        scatter(Acoords(3,i),Acoords(4,i));
        
        Acoords(:,i)
        drawnow
        pause
    end
end

m.Acoords = Acoords;


%%
% figure(1)
% subplot(121)
% scatter(Acoords(1,:),Acoords(2,:),155,'filled'), axis square off
% axis([0 21 0 21])
% subplot(122)
% scatter(Acoords(3,:),Acoords(4,:),155,'filled'), axis square off
% axis([-1 1 -1 1]*2.1)
% 
% 
% %%
% figure(1)
% colormap(cjet)
% subplot(121)
% scatter(Acoords(1,:),Acoords(2,:),55,D(:,11),'filled'), axis square off
% axis([3 18 3 18])
% subplot(122)
% scatter(Acoords(3,:),Acoords(4,:),55,D(:,11),'filled'), axis square off
% axis([-1 1 -1 1]*1.7)
% M=getframe;
% 
% figure(2)
% clf
% imagesc(M.cdata), axis off image
% 
% 
% %loop...

function output = pass_imresize(im,args)
output = im;