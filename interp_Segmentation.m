function [Vol,Vt] = interp_Segmentation(BWt,t_ttl,x,y,z)
H = waitbar(0,'segmenting..');

[X,Y,Z]=sphere(30);
X = 60*X;
Y = 60*Y;
Z = 60*Z;
Vol= [];
Vt = struct('K',[],'vert',[]);
for t = 1:t_ttl
    waitbar(t/t_ttl,H);
    XX = [];
    YY = [];
    ZZ = [];
    for id = 1:numel(X)
        XX = [XX;linspace(x,x+X(id),30)];
        YY = [YY;linspace(y,y+Y(id),30)];
        ZZ = [ZZ;linspace(z,z+Z(id),30)];
    end
    V=interp3(BWt(:,:,:,t),XX,YY,ZZ);
    vert = [];
    for it = 1: numel(X)
        try
            id=find(V(it,:)==1);
            vert = [vert;XX(it,id(1)) YY(it,id(1)) ZZ(it,id(1))];
        catch
        end
    end
%     % second pass
%     xi = mean(vert(:,1));
%     yi = mean(vert(:,2));
%     zi = mean(vert(:,3));
%     XX = [];
%     YY = [];
%     ZZ = [];
%     for id = 1:numel(X)
%         XX = [XX;linspace(xi,xi+X(id),30)];
%         YY = [YY;linspace(yi,yi+Y(id),30)];
%         ZZ = [ZZ;linspace(zi,zi+Z(id),30)];
%     end
%     V=interp3(BWt(:,:,:,t),XX,YY,ZZ);
%     vert = [];
%     for it = 1: numel(X)
%         try
%             id=find(V(it,:)==1);
%             vert = [vert;XX(it,id(1)) YY(it,id(1)) ZZ(it,id(1))];
%         catch
%         end
%     end

    [K,Vol(t)] = convhulln(unique(vert,'rows'));

    Vt(t).K = K;
    Vt(t).vert = unique(vert,'rows');

end

close(H)
