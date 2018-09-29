close all
rootFolderAll = uipickfiles();

for x = 1:length(rootFolderAll)
    rootFolder = rootFolderAll(x)
    loadImages;
    voxel_size = [info.PixelSpacing;info.SliceThickness]';
end

%% - Segmentation using gamma for all to find heart slices
scale = 1;
try
    
    test = info.NumberOfSeriesRelatedInstances;
catch
    info.NumberOfSeriesRelatedInstances = size(PETscanIM,4);
end


t_ttl = double(info.NumberOfTimeSlots);
it = 1;total = t_ttl*(info.heartStop-info.heartStart+1);
numOfSlice = info.NumberOfSlices;
BW = [];BWt=[];scale=5;
w1 = waitbar(0,'generating 3D ROI...')
for timepoints = 1:t_ttl
    heartVoxel = PETscanIM(:,:,:,[(timepoints-1)*numOfSlice+info.heartStart:(timepoints-1)*numOfSlice+info.heartStop]);
    s = size(heartVoxel);
    heartVoxel = reshape(heartVoxel,info.Rows,info.Columns,s(4));
    tform = affine3d([scale 0 0 0;0 scale 0 0; 0 0 scale 0; 0 0 0 1]);
    heartVoxel = imwarp(heartVoxel,tform);
%     heartVoxel = imresize(heartVoxel,scale);
    s = size(heartVoxel);
    if timepoints == 1
        [~,rect]=imcrop(heartVoxel(:,:,round(s(3)/2)));
        close all
    end
    for z = 1:s(3)
        waitbar((timepoints-1+z/s(3))/t_ttl,w1)
        % img crop to get the ROI
        % previous code """
        temp =  imcrop(imadjust(mat2gray(heartVoxel(:,:,z)),[0.4, 0.9],[0, 1]),rect);
        BW(:,:,z)=(temp>mean2(temp)); 
        % """ end previous code

    end
    BWt(:,:,:,timepoints) =BW;
end
close all hidden
%%
% volume calculations:
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
bwLV = zeros(s(1),s(2),s(3),s(4));
%%
[Vol,Vt] = interp_Segmentation(BWt,t_ttl,x,y,z);
%%
clc
t = [1:t_ttl];
figure(7)
plot(t,Vol/max(Vol))
axis([0 t_ttl 0 1])
legend('X','Y','Z','location','best')
EF = @(x,y) (x-y)/x;
% X_axis = EF(max(imX),min(imX))
% Y_axis = EF(max(imY),min(imY))
% Z_axis = EF(max(imZ),min(imZ))

ef = EF(max(Vol),min(Vol));
try
    T1 = [T1;cell2table([rootFolder, {ef}, {info.AcquisitionDate}])];
catch
    T1 = cell2table([rootFolder, {ef}, {info.AcquisitionDate}]);
end
T1
shg
figure(8)
for id = 1:8
ax(id) = subplot(2,4,id);
trisurf(Vt(id).K,Vt(id).vert(:,1),Vt(id).vert(:,2),Vt(id).vert(:,3));
view(0,0)
axis([0 s(1) 0 s(2) 0 s(3)])

end

linkaxes(ax);

figure(9)
for id = 1:8
ax(id) = subplot(2,4,id);
scz = size([squeeze(BWt(:,:,round(z),id)) squeeze(BWt(:,round(y),:,id))]);
scz2 =  size(squeeze(BWt(round(x),:,:,id)));
scz_m = scz(2) -scz2(2);
imshow([squeeze(BWt(:,:,round(z),id)) squeeze(BWt(:,round(y),:,id)) ;squeeze(BWt(round(x),:,:,id)) zeros(scz2(1),scz_m)])

title('xy -yz - xz plane')
axis equal
end
