%--Author: Mohand Alzuhiri
%%----Cone fitting with RANSAC
clear all;clc
load('OutputFiles\WorldPoints');
load('OutputFiles\CameraPoints');
global W3op noc Ind
nof=11;   %--number of frames
noc=5;    %---number of colors
x0(6)=-3;
for i=1:5
    W3op=[];
    for j=1:nof
        W3op=[W3op;double(World_p{j}(Ip3{j}(:,4)==i,:))];
    end    
    ini=[0.2    0.3    0.4    0.5    0.6];
    Ind=1:length(W3op);
    x0(1)=ini(i);
    xo(i,:)=tested(Ind,x0);
    fitLineFcn = @(y)tested(y,x0);
    evalLineFcn = @(model, y) tester2(model,y);
    sampleSize = 30; % number of points to sample per trial
    maxDistance =( 0.05)^2; % max allowable distance for inliers    
    y=Ind;
    [modelRANSAC, inlierIdx] = ransac(y',fitLineFcn,evalLineFcn,sampleSize,maxDistance);
    % x(i,:)=modelRANSAC;
    x(i,:)=tested(inlierIdx,x0);
    x0=x(i,:);
     scatter3(W3op(:,1),W3op(:,2),W3op(:,3),1)
end
disp('The calibration parameters are')
prcal=x
% err
% r=fu1(x0)
save('OutputFiles\CalPara','prcal')
%   106.5245  120.2821  136.1628  152.6631  169.2024   -0.0108    0.0113    1.0226   -1.9619   -1.8619   -1.8619   -1.8619   -1.8619

%%
function r=fu(u)
global W3op Ind
A=[u(2:3),1];
A=A/norm(A);
V=u(4:6);
X=W3op(Ind,:);
P=X-V;
P=P./vecnorm(P,2,2);
r=vecnorm(X-V,2,2).*sin(acos(A*P')-u(1))';
% r=mean(r.^2);

end

function Err=tester2(u,y)
global W3op
A=[u(2:3),1];
A=A/norm(A);
V=u(4:6);
X=W3op;
P=X-V;
P=P./vecnorm(P,2,2);
Err=(vecnorm(X-V,2,2).*sin(acos(A*P')-u(1))').^2;
end

function model=tested(y,x0)
global Ind
Ind=y;
options= optimoptions(@lsqnonlin,'Display','off','Algorithm','levenberg-marquardt','FiniteDifferenceType','Central','MaxFunctionEvaluations',1e6,'MaxIterations',1e6);
[model,ErrNorm,err] = lsqnonlin(@fu,x0,[],[],options);
end

