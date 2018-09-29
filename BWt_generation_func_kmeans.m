function BWt = BWt_generation_func_kmeans(info,PETscanIM)

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
        IMtemp(:,:,z)=temp;
    end
    IM_1col = reshape(IMtemp,[numel(IMtemp),1]);
    BWkmeans = kmeans([IM_1col],2)-1;
    BW = reshape(BWkmeans,[size(IMtemp,1),size(IMtemp,2),size(IMtemp,3)]);
    for z = 1:s(3)
        if nnz(BW(:,:,z)==1) > nnz(BW(:,:,z)==0)
            BW(:,:,z)= ~BW(:,:,z);
        end
    end
    BWt(:,:,:,timepoints) =BW;
end
close all hidden