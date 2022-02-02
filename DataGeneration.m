%--Author: Mohand Alzuhiri
%---A script to automate the extraction of all the camera points from the
%projector images
clc;clear
Wp=[];Ip=[];Ip3=[];Wp3=[];
o=1:34;
Debug=0;
for im_id=1:11
    Ip2=[];Wp2=[];
    [Ip1,Wp1,imx]=PatternDecodFunction(o(im_id));
    Ip2(:,1,1:2)=Ip1(:,1:2);
    Wp2(:,1,1:2)=Wp1(:,1:2);
    Ip{im_id}=Ip2;
    Wp{im_id}=Wp2;
    Ip3{im_id}=Ip1;
    Wp3{im_id}=Wp1;
    if Debug
        figure
        scatter((Wp1(:,2)),Wp1(:,1));
        hold on
        scatter((Ip1(:,2)),Ip1(:,1));
        hold off
        axis equal
        imxr=rgb2gray(imx);
        for i=1:length(Ip1)
            imx(round(Ip1(i,2)),round(Ip1(i,1)),:)=255;
        end
        imshow(imx)
        xlim([-1000,1000]);
        ylim([-1000,1000]);
        pause(3)
    end
end
save('OutputFiles\CameraPoints','Ip','Ip3')
disp('done')

