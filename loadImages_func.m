function [info,PETscanIM]=loadImages_func(rootFolder)
% rootFolder = 'C:\Users\Jeron\OneDrive\PET images\directly\1.2.826.0.1.3417726.3.2179194607\1.2.826.0.1.3417726.3.110485.20170216102533650\';

close all hidden
try
    load([rootFolder{1} '\PETscanIM.mat'])
    load([rootFolder{1} '\info.mat'])
catch
    extrtag  = '*.dcm';
    scale = 1;
    images = dir([rootFolder{1} '\' extrtag]);
    info = dicominfo([rootFolder{1} '\' images(1).name]);
    try
        PETscanIM = zeros(info.Width*scale,info.Height*scale,1,info.NumberOfSeriesRelatedInstances);
    catch
        info.NumberOfSeriesRelatedInstances = length(images);
        PETscanIM = zeros(info.Width*scale,info.Height*scale,1,info.NumberOfSeriesRelatedInstances);
    end
    wb = waitbar(0,'Start');
    tmax=info.NumberOfSeriesRelatedInstances;
    home
    for id = 1:tmax
        waitbar(id/tmax,wb,['reading images  #' num2str(id)])
        try
            info = dicominfo([rootFolder{1} '\' images(id).name]);
            [X,~] = dicomread([rootFolder{1} '\' images(id).name]);
            im = mat2gray(double(X));
            im = imresize(im,scale,'bilinear');
            PETscanIM(:,:,1,info.ImageIndex) = im;
        catch
            disp(['error in image number ' num2str(id)])
        end
    end
    
    waitbar(id/tmax,wb,['saving...'])
    save([rootFolder{1} '\PETscanIM.mat'],'PETscanIM')
    save([rootFolder{1} '\info.mat'],'info')
    close(wb)
end
%%


K = zeros(1,info.NumberOfSlices);
for slices = 1: info.NumberOfSlices
    temp = mat2gray(PETscanIM(:,:,1,slices))>0.4;
    K(slices) = sum(temp(:));
end
figure(2001)
plot(K)
for slices = 1: info.NumberOfSlices
    numberedSlices(:,:,1,slices) = double(slices)*double(ones(info.Height,info.Width));
end
% [a] = montage(PETscanIM(:,:,1,1:info.NumberOfSlices))
%%
figure(1001)
[b] = montage(numberedSlices(:,:,1,1:info.NumberOfSlices));
index = b.CData;
[a] = montage(PETscanIM(:,:,1,1:info.NumberOfSlices));
heartSlices = a.CData;
shg
[Arow,Acol]=ginputc(2,'Color','y','Showpoints',true);
heartstart=index(floor(Acol(1)),floor(Arow(1)));
heartstop=index(floor(Acol(2)),floor(Arow(2)));



[b] = montage(numberedSlices(:,:,1,heartstart:heartstop));
index = b.CData;
[a] = montage(PETscanIM(:,:,1,heartstart:heartstop));

[Arow,Acol]=ginputc(2,'Color','y','Showpoints',true);
heartstart=index(floor(Acol(1)),floor(Arow(1)));
heartstop=index(floor(Acol(2)),floor(Arow(2)));
close
info.heartStart = heartstart;
info.heartStop = heartstop;
close all hidden


