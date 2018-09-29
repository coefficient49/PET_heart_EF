function BWt = BWt_generation_func(info,PETscanIM)

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
    heartVoxel = imresize3(heartVoxel,5);
    s = size(heartVoxel);
    if timepoints == 1
        [~,rect]=imcrop(heartVoxel(:,:,round(s(3)/2)));
        close all
    end
    for z = 1:s(3)
        waitbar((timepoints-1+z/s(3))/t_ttl,w1)
        IM = mat2gray(heartVoxel(:,:,z));
        temp =  imcrop(IM,rect);
        temp = imsharpen(temp,'Radius',2,'Amount',1);
%         temp = adapthisteq(temp);
        temp = imadjust(temp,[0.3, 0.9],[0, 1]);
        BW(:,:,z)=(temp>0.5);
    end
    BWt(:,:,:,timepoints) =BW;
end
close all hidden