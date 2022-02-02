%--Author: Mohand Alzuhiri
%----Pattern decodification function
function [Ip,Wp,imx]=PatternDecodFunction(io)
%--The final version of the code to reconstruct multiring patterns
pr=[3,3,2,2,1,1,3,1,2]; %% projected sequene
pr=pr*10+circshift(pr,-1);
Code_L=3;
%%- Projected pattern coordinates:
ploc(1)=115;
for i=1:9
    ploc(i+1)=ploc(i)+15;
end
L=length(pr);  %%- length of the projected length
%%- setting threshold for ninarization
se = strel('rectangle',[3,10]);  %% Morph cleaning structure
P='./Undestorted images/';
im=((imread([P,'Proj',num2str(io, '%02.f'),'.png'])));
% im=fliplr(im);
imx=im;
a=(size(im,2)-size(im,1))/2+1;
b=size(im,2)-a+1;
im=im(:,a:b,:);
im_max=rgb2gray(im);  %%- intensity of the image
im_max=double(medfilt2(im_max));    %%- Median filtering of the intensity
rmin=0.2;
rmax=1;
R_len=round((rmax-rmin)*size(im,2)/2);
Angle_len=720;
[xR,yR,imP]=conversionHD(double(im),R_len,Angle_len,rmin,rmax,1);  %-convert to Polar coordinates
[xR,yR,imP1]=conversionHD(im_max,R_len,Angle_len,rmin,rmax,0);  %-convert to Polar coordinates
h1=[1,2,1];
h1=[-repmat(h1,[5,1]);zeros(1,3);repmat(h1,[5,1])];   %%%--filtered gradient
gg=zeros(size(imP1));
gg1=imfilter(imP1,h1,'symmetric');              %---first gradient filter
gg2=imfilter(gg1,h1,'symmetric');                %--- Second gradient filter
%---Binarization and cleaning
THH=0;
gg(gg2>=THH)=0;
gg(gg2<THH)=1;
gg(imP1<0)=0;
gg = imclose(gg,se);
edges=bwmorph(gg,'clean');
edges=[fliplr(edges(:,end-9:end)),edges,fliplr(edges(:,1:10))];
edges=bwmorph(edges,'remove');
edges=edges(:,11:end-10);
CC = bwconncomp(edges);
%Iterates over the CC list, and searches for the CC which represents the
%pipe
ccMask = zeros(size(edges));
for ii=1:length(CC.PixelIdxList)
    %ignore small CC
    if(length(CC.PixelIdxList{ii})<100)
        continue;
    end
    %extracts CC edges
    ccMask(CC.PixelIdxList{ii}) = 1;
end
edges= ccMask;
edges(1:50,:)=0;
edges=double(edges);
sub=zeros(size(imP1));
sub1=sub;u23=zeros(size(imP));
imP(:,:,1)=imP(:,:,1)/1.3;
imP(:,:,3)=imP(:,:,3);
% find the average of each stripe
for i=1:size(imP1,2)
    o=find(edges(:,i));
    for jj=1:length(o)-1
        mm=mean(gg(o(jj):o(jj+1),i));
        if mm<1 && (o(jj+1)-o(jj))<20
            id1=sum(gg2(o(jj):o(jj+1),i).*(o(jj):o(jj+1))')/sum(gg2(o(jj):o(jj+1),i));
            mk=0;
            id=round(id1);
            if ~isnan(id) && id<450 && id>21
                mk=mean(imP1(id:id+6,i));
            end
            if  mk<2
            else
                m1=mean(imP((id-20):(id-2),i,1));
                m2=mean(imP((id-20):(id-2),i,2));
                m3=mean(imP((id-20):(id-2),i,3));
                u23((id-30):(id-2),i,1)=m1;
                u23((id-30):(id-2),i,2)=m2;
                u23((id-30):(id-2),i,3)=m3;
                [m,in1]=max([m1,m2,m3]);
                if in1<2 && (m1-m2)>20
                    in1=1;
                elseif in1>2 && (m3-m2)>20
                    in1=3;
                else
                    in1=2;
                end
                m1=mean(imP((id+2):(id+20),i,1));
                m2=mean(imP((id+2):(id+20),i,2));
                m3=mean(imP((id+2):(id+20),i,3));
%                 u23((id-30):(id-2),i,1)=m1;
%                 u23((id-30):(id-2),i,2)=m2;
%                 u23((id-30):(id-2),i,3)=m3;
                [m,in2]=max([m1,m2,m3]);
                if in2<2 && (m1-m2)>20
                    in2=1;
                elseif in2>2 && (m3-m2)>20
                    in2=3;
                else
                    in2=2;
                end
                sub(id,i)=(in1*10+in2);
                sub1(id,i)=id1;
            end
        end
    end
end
edges1=sub;
%%
%%--Code matching
Ip=[]; Wp=[];DD3=[]; %-initialize the matrices
for n=1:1:720
    [loc,r,vec]=find(edges1(:,n));
    nj=1;
    for ii=1:1:L-Code_L
        for jj=nj:1:nj+5
            if jj>(length(loc)-Code_L)
                break;
            end
            if ii>(length(pr)-Code_L)
                break;
            end
            if vec(jj:jj+Code_L-1)'==pr(ii:ii+Code_L-1)
                r2=ploc(ii:ii+Code_L-1);   %% projector
                r1=(sub1(loc(jj:jj+Code_L-1),(n))'+rmin*size(im,2)/2);
                r1x=r1.*cos(2*pi/180*(n-1)/4);
                r1y=r1.*sin(2*pi/180*(n-1)/4);
                w1x=r2.*cos(2*pi/180*(n-1)/4);
                w1y=r2.*sin(2*pi/180*(n-1)/4);
                Ip=[Ip,[r1y;r1x;repmat(n,[1,Code_L]);(ii:ii+Code_L-1)]];
                Wp=[Wp,[w1y;w1x;[ii:ii+Code_L-1];ones(1,length(w1x))*n]];
                nj=jj+1;
                break
            end
            
        end
    end
end
%%
%---Triangulation process
[Wp,po]=unique(Wp','rows');
Ip=Ip';
Ip=Ip(po,:);
Ip(:,2)=Ip(:,2)+615.5;
Ip(:,1)=Ip(:,1)+831.5;
Wp(:,2)=Wp(:,2)+615.5;
Wp(:,1)=Wp(:,1)+831.5;
%%
Wp(max(Ip')>1232,:)=[];
Ip(max(Ip')>1232,:)=[];
Ip=round(Ip);
IMtest=imx;
for kc=1:length(Ip)
    IMtest(Ip(kc,2),Ip(kc,1),:)=240;
end
r=(1664-1232)/2;
imshow(IMtest(:,r+1:1664-r,:))
end


