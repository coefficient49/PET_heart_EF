close all
rootFolderAll = uipickfiles();

for ii = 1:length(rootFolderAll)
    rootFolder = rootFolderAll(ii)
    [Data(ii).info,Data(ii).PETscanIM]=loadImages_func(rootFolder);
    
end
%%
for ii = 1:ii
%     profile on
%     Data(ii).BWt = BWt_generation_func(Data(ii).info,Data(ii).PETscanIM);
    Data(ii).BWt = BWt_generation_func_kmeans(Data(ii).info,Data(ii).PETscanIM);
%     Data(ii).BWt = BWt_generation_func_kmeans_n_thresh(Data(ii).info,Data(ii).PETscanIM);
%     profile viewer
    [Data(ii).x,Data(ii).y,Data(ii).z]=get_Centroid(Data(ii).BWt);
end
%%
for ii = 1:length(rootFolderAll)
    t_ttl = double(Data(ii).info.NumberOfTimeSlots)
    try
        [Data(ii).Vol,Data(ii).Vt] = interp_Segmentation(Data(ii).BWt,t_ttl,Data(ii).x,Data(ii).y,Data(ii).z);
    catch
        Data(ii).Vol = [0,1];
        Data(ii).Vt = [];
        close all hidden
    end
end
%%
EF = @(x,y) (x-y)/x;
for ii = 1:length(rootFolderAll)
    Data(ii).ef = EF(max(Data(ii).Vol),min(Data(ii).Vol));
    try
        T1 = [T1;cell2table([rootFolderAll(ii), {Data(ii).ef}, {Data(ii).info.AcquisitionDate}])];
    catch
        T1 = cell2table([rootFolderAll(ii), {Data(ii).ef}, {Data(ii).info.AcquisitionDate}]);
    end
end
T1
T1.Properties.VariableNames = {'filepath', 'EjectionFraction', 'Date'};
writetable(T1,['testdata' datestr(now,'ddmmyyyy_HH_MM') '.xls'])