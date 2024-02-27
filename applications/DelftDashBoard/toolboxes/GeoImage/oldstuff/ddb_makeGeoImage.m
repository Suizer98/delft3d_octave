function [xgl,ygl,c]=ddb_makeGeoImage(xl,yl,varargin)

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
    a=0.8;
    res=npix/(xmax-xmin);
    zmlev=round(log2(res/a));
    zmlev=max(zmlev,4);
    zmlev=min(zmlev,19);
    zmlev;
end

% Get tile data
[url,lon, lat,x,y] = url2image('tile2url',[xmin xmax],[ymin ymax], zmlev);
[quad, lon_mm, lat_mm] = url2image('tile2url', [xmin xmax],[ymin ymax], zmlev,'quadonly', 'whatever');
[lims, tiles_bb] = url2image('quadcoord', quad);

nx=size(url,1);
ny=size(url,2);

if nx*ny>100
    disp('This will take forever!');
    xgl=[];
    ygl=[];
    c=[];
    return
end

rg=zeros(nyg,nxg);
gg=zeros(nyg,nxg);
bg=zeros(nyg,nxg);
rg(rg==0)=NaN;
gg(gg==0)=NaN;
bg(bg==0)=NaN;

n=0;

wb = awaitbar(0,'Generating Georeferenced Image ...');

for j=1:ny
    for i=1:nx

        n=n+1;

        url1=url{i,j};

        xltile(1)=tiles_bb(n,1);
        xltile(2)=tiles_bb(n,2);
        yltile(1)=tiles_bb(n,3);
        yltile(2)=tiles_bb(n,4);
        c=imread(url1);

        if ndims(c)==3

            r=c(:,:,1);
            g=c(:,:,2);
            b=c(:,:,3);

            clear c

            r=flipud(r);
            g=flipud(g);
            b=flipud(b);

            r=double(r);
            g=double(g);
            b=double(b);

            xx1=xltile(1);
            xx2=xltile(2);
            yy1=yltile(1);
            yy2=yltile(2);

            nxx=size(r,2);
            nyy=size(r,1);
            dx=(xx2-xx1)/(nxx-1);
            dy=(yy2-yy1)/(nyy-1);

            xx=xx1:dx:xx2;
            yy=yy1:dy:yy2;

            %        res=156543.04 * cos(pi*yyy/180) / (2 ^ zmlev);
            y1=yltile(1);
            y2=yltile(2);
            a1=(y2-y1)/(sin(pi*y2/180)-sin(pi*y1/180));
            a2=y2-a1*sin(pi*y2/180);
            yyss=a1*sin(pi*yy/180)+a2;

            r=interp1(yyss,r,yy);
            g=interp1(yyss,g,yy);
            b=interp1(yyss,b,yy);

            r=interp2(xx,yy,r,xg,yg);
            g=interp2(xx,yy,g,xg,yg);
            b=interp2(xx,yy,b,xg,yg);

            isn=isnan(rg);

            rg(isn)=r(isn);
            gg(isn)=g(isn);
            bg(isn)=b(isn);
        end

        str=['Processing tile ' num2str(n) ' of ' num2str(nx*ny) ' ...'];
        [hh,abort2]=awaitbar(n/(nx*ny),wb,str);

        if abort2 % Abort the process by clicking abort button
            break;
        end;
        if isempty(hh); % Break the process when closing the figure
            break;
        end;
    end
    if abort2 % Abort the process by clicking abort button
        break;
    end;
    if isempty(hh); % Break the process when closing the figure
        break;
    end;
end

if ~isempty(hh)
    close(wb);
end

clear c

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

