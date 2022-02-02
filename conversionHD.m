%--Author: Mohand Alzuhiri
%---Rectangular to plar domain conversion
function [xR,yR,imP]=conversionHD(imRg,M,N,rMin,rMax,RGB)
imR=imRg(:,:,1);
[Mr, Nr] = size(imR); % size of rectangular image
Om = (Mr+1)/2; % co-ordinates of the center of the image
On = (Nr+1)/2;
sx = (Mr-1)/2; % scale factors

delR = (rMax - rMin)/(M-1);
delT = 2*pi/N;

ri = 1:M;ti = 1:N;
% t=linspace(0,2*pi,360);
    r = rMin + (ri - 1)*delR;
    t = (ti - 1)*delT;
    x = r.'*cos(t);
    y = r.'*sin(t);
    xR= round(x*sx + Om);  
    yR= round(y*sx + On); 
    
    
[xx,yy]=meshgrid(1:Nr,1:Mr);
if RGB
imP(:,:,1)=interp2(xx,yy,double(imRg(:,:,1)),yR,xR,'bilinear');
imP(:,:,2)=interp2(xx,yy,double(imRg(:,:,2)),yR,xR,'bilinear');
imP(:,:,3)=interp2(xx,yy,double(imRg(:,:,3)),yR,xR,'bilinear');
else
    imP=interp2(xx,yy,double(imRg),yR,xR,'bilinear');
end

% imP=uint8(imP);
% figure;imagesc(colordededge(imP))

    
end
% end