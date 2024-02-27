function [xgl,ygl,c]=ddb_makeGeoImageGE(xl,yl,varargin)

xgl=[];
ygl=[];
c=[];

npix=1024;
zmlev=0;
coordsys=[];

jpgname=[];
jgwname=[];

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'zoomlevel'}
                zmlev=varargin{i+1};
            case{'nrpix'}
                npix=varargin{i+1};
            case{'coordinatesystem'}
                coordsys=varargin{i+1};
            case{'jpgname'}
                jpgname=varargin{i+1};
            case{'jgwname'}
                jgwname=varargin{i+1};
        end
    end
end

% Generate target grid
dx=(xl(2)-xl(1))/npix;
dy=dx;
xgl=xl(1):dx:xl(2);
ygl=yl(1):dy:yl(2);
nxg=length(xgl);
nyg=length(ygl);
[xg,yg]=meshgrid(xgl,ygl);

if ~isempty(coordsys)
    cs0=coordsys;
    cs1.Name='WGS 84';
    cs1.Type='geo';
    [xg,yg]=ddb_coordConvert(xg,yg,cs0,cs1);
end

% Determine zoom level
xmin=min(min(xg));
xmax=max(max(xg));
ymin=min(min(yg));
ymax=max(max(yg));
if zmlev==0
    zmlev=round(log2(npix*180/256/(xmax-xmin)));
    zmlev=max(zmlev,4);
    zmlev=min(zmlev,19);
end

ret1=ddb_getCoordinatesFromAddress(ddb_getQuadtreeAddress(xl(1),yl(1),zmlev));
ret2=ddb_getCoordinatesFromAddress(ddb_getQuadtreeAddress(xl(2),yl(1),zmlev));
ret3=ddb_getCoordinatesFromAddress(ddb_getQuadtreeAddress(xl(1),yl(2),zmlev));
ret4=ddb_getCoordinatesFromAddress(ddb_getQuadtreeAddress(xl(2),yl(2),zmlev));

epsi=1e-06;

yTemp=yl(1);
I=[];
curQTA=ddb_getQuadtreeAddress(xl(1),yTemp,zmlev);
curQTA2=ddb_getQuadtreeAddress(xl(1),yTemp,zmlev);

% Calculate approximate number of total tiles
totTiles=(1+ceil(diff(xl)./abs(diff([ret1.longmin ret1.longmax])))).*(1+ceil(diff(yl)./abs(diff([ret1.latmin ret1.latmax]))));
if totTiles>150
    disp('This will take forever!');
    xgl=[];
    ygl=[];
    c=[];
    return
end

wb = awaitbar(0,'Generating Georeferenced Image ...');
numOfTiles=0;

while ~strcmp(curQTA2,ddb_getQuadtreeAddress(xl(1),yl(2),zmlev))
    curQTA=ddb_getQuadtreeAddress(xl(1),yTemp,zmlev);
    curQTA2=ddb_getQuadtreeAddress(xl(1),yTemp,zmlev);
    ret=ddb_getCoordinatesFromAddress(curQTA2);
    try
        tempI=imread(['http://kh.google.com/kh?v=3&t=' ddb_getQuadtreeAddress(xl(1),yTemp,zmlev)]);
    catch
        tempI=uint8(zeros(256,256,3));
    end
    numOfTiles=numOfTiles+1;
    while ~strcmp(curQTA,ddb_getQuadtreeAddress(xl(2),yTemp,zmlev))
        try
            temp2I=imread(['http://kh.google.com/kh?v=3&t=' ddb_getQuadtreeAddress(ret.longmax+epsi,ret.lat,zmlev)]);
        catch
            temp2I=uint8(zeros(256,256,3));
        end
        tempI=[tempI temp2I];
        curQTA=ddb_getQuadtreeAddress(ret.longmax+epsi,ret.lat,zmlev);
        ret=ddb_getCoordinatesFromAddress(curQTA);
        numOfTiles=numOfTiles+1;
        str=['Processing tile ' num2str(numOfTiles) ' ...'];
        [hh,abort2]=awaitbar(numOfTiles/totTiles,wb,str);
        if abort2 % Abort the process by clicking abort button
            break;
        end;
        if isempty(hh); % Break the process when closing the figure
            break;
        end;
    end
    I=[tempI;I];
    yTemp=ret.latmin+epsi;
%     curQTA=ddb_getQuadtreeAddress(xl(1),yTemp,zmlev);
%     curQTA2=ddb_getQuadtreeAddress(xl(1),yTemp,zmlev);
%     ret=ddb_getCoordinatesFromAddress(curQTA2);
    if abort2 % Abort the process by clicking abort button
        break;
    end;
    if isempty(hh); % Break the process when closing the figure
        break;
    end;
end

if ~isempty(wb)
    close(wb);
end

if isempty(I)
    try
        I=imread(['http://kh.google.com/kh?v=3&t=' ddb_getQuadtreeAddress(xl(1),yl(1),zmlev)]);
    catch
        I=uint8(zeros(256,256,3));
    end
end

% check if image is not totally black
if max(max(max(I)))==0
    disp('Temporarily no access to Google map server!');
    xgl=[];
    ygl=[];
    c=[];
    return
end

% latStep=min([abs(ret1.latmax-ret1.latmin) abs(ret2.latmax-ret2.latmin) abs(ret3.latmax-ret3.latmin) abs(ret4.latmax-ret4.latmin)]);
% longStep=min([abs(ret1.longmax-ret1.longmin) abs(ret2.longmax-ret2.longmin) abs(ret3.longmax-ret3.longmin) abs(ret4.longmax-ret4.longmin)]);
%
% [xt,yt] = meshgrid(xl(1):longStep:xl(end),yl(1):latStep:yl(end));
% I=[];
% tempI=[];
% hW=waitbar(0,'Please wait while downloading tiles...');
% for m=1:size(xt,1)
%     for n=1:size(xt,2)
%         try
%             temp2I=imread(['http://kh.google.com/kh?v=3&t=' ddb_getQuadtreeAddress(xt(m,n),yt(m,n),zmlev)]);
%         catch
%             temp2I=uint8(zeros(256,256,3));
%         end
%         tempI=[tempI temp2I];
%     end
%     I=[tempI;I];
%     tempI=[];
%     waitbar(m/size(xt,1),hW);
% end
% close(hW);

xl2=[min([ret1.longmin ret1.longmax ret2.longmin ret2.longmax]) max([ret1.longmin ret1.longmax ret2.longmin ret2.longmax])];
yl2=[min([ret2.latmin ret2.latmax ret3.latmin ret3.latmax]) max([ret2.latmin ret2.latmax ret3.latmin ret3.latmax])];
[xx,yy]=meshgrid([xl2(1):diff(xl2)/(size(I,2)-1):xl2(2)],[yl2(1):diff(yl2)/(size(I,1)-1):yl2(2)]);

rg=interp2(xx,yy,flipud(squeeze(I(:,:,1))),xg,yg,'nearest');
gg=interp2(xx,yy,flipud(squeeze(I(:,:,2))),xg,yg,'nearest');
bg=interp2(xx,yy,flipud(squeeze(I(:,:,3))),xg,yg,'nearest');

if ndims(rg)==2

    c(:,:,1)=rg;
    c(:,:,2)=gg;
    c(:,:,3)=bg;
    c=uint8(c);

    if ~isempty(jpgname)
        rg=rot90(rg');
        gg=rot90(gg');
        bg=rot90(bg');
        cjpg(:,:,1)=rg;
        cjpg(:,:,2)=gg;
        cjpg(:,:,3)=bg;
        cjpg=uint8(cjpg);
        imwrite(cjpg,[jpgname],'jpeg');
    end

    if ~isempty(jgwname)
        dx=(xl(2)-xl(1))/(nxg-1);
        dy=(yl(2)-yl(1))/(nyg-1);
        fid=fopen([jgwname],'wt');
        fprintf(fid,'%s\n',num2str(dx));
        fprintf(fid,'%s\n',num2str(0.0));
        fprintf(fid,'%s\n',num2str(0.0));
        fprintf(fid,'%s\n',num2str(-dy));
        fprintf(fid,'%s\n',num2str(xl(1)));
        fprintf(fid,'%s\n',num2str(yl(2)));
        fclose(fid);
    end

end

