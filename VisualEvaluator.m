%----Visual demmostration of the calibration results
% clear all;clc;
% close all
load para3x;
load points.mat;
load('Calresults.mat');
cl=9;
Mode='Three';
if strcmp(Mode,'Two')
    Code_L=2;
else
    Code_L=3;
end
io=2;   %---the index of the reconstructed frame
pr=[3,3,2,2,1,1,3,1,2]; %% projected sequene
pr=pr(1:cl);pr=pr*10+circshift(pr,-1);  %--Create a pair for edges neighbors
L=length(pr);  %--Length of the projected length
width=1664;height=1232;R=1.5;   %----Image parameters
THS1=200;THS2=16;  %--Thresholds for segmentation
%---Images file to be decoded
Tube=0;  %---choose if u want to have an external image
if Tube
    im=imread(['GMT1\im',num2str(1),'.png']);
    im(:,:,1)=im(:,:,1)/1.3;
    im(:,:,3)=im(:,:,3)*1.1;
    a=(size(im,2)-size(im,1))/2+1;b=size(im,2)-a+1;im=im(:,a:b,:);  %--Crop to square
    im_max=double(medfilt2(rgb2gray(im)));    %%- Median filtering of the intensity image
    rmin=0.05;rmax=1;Angle_len=720;   %---Polar conversion parameters
    R_len=round((rmax-rmin)*size(im,2)/2); %--Radius of the image in pixels
    [xR,yR,imP]=conversionHD(double(im),R_len,Angle_len,rmin,rmax,1);  %-Convert to Polar coordinates RGB
    [xR,yR,imP1]=conversionHD(im_max,R_len,Angle_len,rmin,rmax,0);  %-Convert to Polar coordinates Gray
    %================ imagesegmentation=======================================
    h1=[-1,-1,-1,-1,-1,0,1,1,1,1,1]';   %%%--Filtered gradient
    se = strel('rectangle',[3,10]);  %---Morph cleaning structure
    gg=zeros(size(imP1));
    gg1=imfilter(imP1,h1,'symmetric');              %---First gradient filter
    gg2=imfilter(gg1,h1,'symmetric');               %---Second gradient filter
    %---Binarization and cleaning
    THH=20;                                 %---Binarization threshold
    gg(gg2>=THH)=0;gg(gg2<THH)=1;
    gg = imclose(gg,se);
    edges=bwmorph(gg,'clean');
    edges(1:50,:)=1;
    edges=[fliplr(edges(:,end-9:end)),edges,fliplr(edges(:,1:10))];
    edges=bwmorph(edges,'open');
    edges=bwmorph(edges,'open');
    edges=bwmorph(edges,'close');
    edges=bwmorph(edges,'remove');
    edges=edges(:,11:end-10);
    CC = bwconncomp(edges);
    %--Cleaning with connected component analysis
    ccMask = zeros(size(edges));
    for ii=1:length(CC.PixelIdxList)
        %--Ignore small CC
        if(length(CC.PixelIdxList{ii})<50)
            continue;
        end
        %--Extracts CC edges
        ccMask(CC.PixelIdxList{ii}) = 1;
    end
    edges= ccMask;
    edges(1:20,:)=0;
    edges(end-20:end,:)=0;
    edges=double(edges);
    sub=zeros(size(imP1));
    sub1=sub;
    u23=zeros(size(imP));
    Int=mean(imP(250:end,:,:),3);
    Intm=max(Int);
    imP=imP./Intm*130;
    %---Find the average of each stripe
    for i=1:size(imP1,2)
        o=find(edges(:,i));
        for jj=1:length(o)-1
            mm=mean(gg(o(jj):o(jj+1),i));
            if mm<0.9 && (o(jj+1)-o(jj))<25
                id1=sum(gg2(o(jj):o(jj+1),i).*(o(jj):o(jj+1))')/sum(gg2(o(jj):o(jj+1),i));
                id=round(id1);
                if id<31 || id>565 || isnan(id)
                else
                    m1=mean(imP((id-18):(id-10),i,1));
                    m2=mean(imP((id-18):(id-10),i,2));
                    m3=mean(imP((id-18):(id-10),i,3));
                    [m,in1]=max([m1,m2,m3]);
                    %                 u23((id-30):(id-2),i,1)=m1;
                    %                 u23((id-30):(id-2),i,2)=m2;
                    %                 u23((id-30):(id-2),i,3)=m3;
                    if in1<2 && (m1-m3)>5
                        in1=1;
                    elseif in1<3 && m2>100
                        in1=2;
                    else
                        in1=3;
                    end
                    m1=mean(imP((id+10):(id+18),i,1));
                    m2=mean(imP((id+10):(id+18),i,2));
                    m3=mean(imP((id+10):(id+18),i,3));
                    %                 u23((id-30):(id-2),i,1)=m1;
                    %                 u23((id-30):(id-2),i,2)=m2;
                    %                 u23((id-30):(id-2),i,3)=m3;
                    [m,in2]=max([m1,m2,m3]);
                    if in2<2 && (m1-m3)>5
                        in2=1;
                    elseif in2<3 && m2>100
                        in2=2;
                    else
                        in2=3;
                    end
                    sub(id,i)=(in1*10+in2);
                    sub1(id,i)=id1;
                end
            end
            
        end
        
    end
    edges1=sub;
    %%--Code matching
    Ip=[]; Wp=[];DD3=[];Dx=[]; %-initialize the matrices
    for n=1:1:720
        if strcmp(Mode,'Two')
            Code_L=2;
        end
        [loc,r,vec]=find(edges1(:,n));
        nj=1;
        for ii=1:1:L-Code_L
            for jj=nj:1:nj+5
                if jj>(length(loc)-Code_L)
                    break;
                end
                if loc(jj)>170
                    Code_L=3;
                end
                if ii>(length(pr)-Code_L)
                    break;
                end
                if vec(jj:jj+Code_L-1)'==pr(ii:ii+Code_L-1)
                    r1=(sub1(loc(jj:jj+Code_L-1),(n))'+rmin*size(im,2)/2);
                    r1x=r1.*cos(2*pi/180*(n-1)/4);
                    r1y=r1.*sin(2*pi/180*(n-1)/4);
                    Ip=[Ip,[r1y;r1x;repmat(n,[1,Code_L])]];
                    Dx=[Dx,ii:ii+Code_L-1];
                    nj=jj+1;
                    break
                end
            end
        end
    end
    [Ip,po]=unique(Ip','rows');
    Dx=Dx(po);
    Ip(:,2)=Ip(:,2)+615.5-1;
    Ip(:,1)=Ip(:,1)+831.5-1;
    Knew(1,1)=470;Knew(2,2)=Knew(1,1);Knew(1,2)=0;
    Ip(:,1:2)=cv.fisheyeUndistortPoints(Ip(:,1:2),K,D,'P',Knew);
    Ip(:,2)=Ip(:,2)-615.5+1;
    Ip(:,1)=Ip(:,1)-831.5+1;
    Ip(:,5)=Dx;
    Dxop=Dx;
else
    load('tot2.mat')
    Ip=Ip3{io};
    Ip(:,2)=Ip(:,2)-615.5;
    Ip(:,1)=Ip(:,1)-831.5;
end
fc=Knew(1,1);

%---3D triangulation
Points3D=[];
for i=1:1:5
    IPX=Ip(Ip(:,4)==i,:);
    u=prcal(i,:);
    %---------Angle------
    theta=u(1);
    %----Image vector----
    D=IPX(:,1:2);D(:,3)=fc;
    D=D./vecnorm(D')';
    %---Cone main vector
    V=[u(2:3),1];
    V=V/vecnorm(V);
    %---Cone vertex
    C=u(4:6);
    %---System origin (camera)
    O=[0,0,0];
    %--Vector from vertex to origin
    CO=O-C;
    %--Ray cone intersection
    a=(D*V').^2-cos(theta)^2;
    b=2*((D*V').*(CO*V')-D*CO'*cos(theta)^2);
    c=(CO*V').^2-CO*CO'*cos(theta)^2;
    del=b.^2-4*a.*c;
    t=(-b-sqrt(del))./(2*a);
    P=O+(t).*D;    %----Intersection points with the cone
    Points3D=[Points3D;P];
end
% figure;
hold on
Points3D(Points3D(:,3)>8,:)=[];
Points3D(Points3D(:,3)<1,:)=[];

pcshow(Points3D,[0,0,1])
hold on
if ~Tube
    hold on;
    pcshow(World_p{io},[1,0,1]);
    hold off
end
axis equal
xlabel('x');ylabel('y');zlabel('z');
set(gca,'color','w');
set(gcf,'color','w');

set(gca, 'XColor', [0.15 0.15 0.15], 'YColor', [0.15 0.15 0.15], 'ZColor', [0.15 0.15 0.15]);


