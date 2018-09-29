function [x,y,z]=get_Centroid(BWt)
imx = [];imy = [];imz = [];
imZ = [];imY = [];imX = [];
s= size(BWt);
SSS = sum(BWt,4);
YZ = squeeze(SSS(round(s(1)/2),:,:));
imagesc(YZ)
axis equal
[z,y]=ginput(1);
XY = squeeze(SSS(:,:,round(z)));
close all
imagesc(XY)
axis equal
[x,y]=ginput(1);
close all