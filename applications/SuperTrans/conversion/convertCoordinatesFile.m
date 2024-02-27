function convertCoordinatesFile(filePath,epsgIn,epsgOut)

[fileDir,fileName,fileExt] = fileparts(filePath);

switch fileExt
    case '.ldb'
        ldb = landboundary('read',filePath);
        [ldbNew(:,1) ldbNew(:,2)] = convertCoordinates(ldb(:,1),ldb(:,2),'CS1.code',epsgIn,'CS2.code',epsgOut);
        landboundary('write',[fileDir,filesep,fileName,'_conv_',num2str(epsgOut),'.ldb'],ldbNew);
    case '.pol'
        ldb = landboundary('read',filePath);
        [ldbNew(:,1) ldbNew(:,2)] = convertCoordinates(ldb(:,1),ldb(:,2),'CS1.code',epsgIn,'CS2.code',epsgOut);
        landboundary('write',[fileDir,filesep,fileName,'_conv_',num2str(epsgOut),'.pol'],ldbNew);
    case '.grd'
        grd = wlgrid('read',filePath);
        [grd.X,grd.Y] = convertCoordinates(grd.X,grd.Y,'CS1.code',epsgIn,'CS2.code',epsgOut);
        grd = wlgrid('write',[fileDir,filesep,fileName,'_conv_',num2str(epsgOut),'.grd'],grd);
        
    case '.xyz'
        xyz = importdata(filePath);
        [xyz(:,1) xyz(:,2)] = convertCoordinates(xyz(:,1),xyz(:,2),'CS1.code',epsgIn,'CS2.code',epsgOut);
        fid = fopen([fileDir,filesep,fileName,'_conv_',num2str(epsgOut),'.xyz'],'w');
        fprintf(fid,[repmat('%16.7e',1,size(xyz,2)) '\n'],xyz');
        fclose(fid);  
    case '.xyn'        
        [xyn.x,xyn.y,xyn.name] = textread(filePath,'%f%f%s');
        [xyn.x2,xyn.y2] = convertCoordinates(xyn.x,xyn.y,'CS1.code',epsgIn,'CS2.code',epsgOut);
        %% wirting xyn file
        fid = fopen([fileDir,filesep,fileName,'_conv_',num2str(epsgOut),'.xyn'],'w');
        for oo = 1:length(xyn.x2)
            fprintf(fid,'%s \n',[num2str(xyn.x2(oo)),'  ',num2str(xyn.y2(oo)),' ',xyn.name{oo}]);
        end
        fclose(fid)
    case '.jgw'        
        world=load(filePath);
        [world(5),world(6)] = convertCoordinates(world(5),world(6),'CS1.code',epsgIn,'CS2.code',epsgOut);
        fid = fopen([fileDir,filesep,fileName,'_conv_',num2str(epsgOut),fileExt],'w');
        fprintf(fid,'%16.7e \n',world');
        fclose(fid)
end
