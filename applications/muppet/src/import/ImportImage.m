function DataProperties=ImportImage(DataProperties,j)
alpha=[];
frm=DataProperties(j).FileName(end-2:end);
switch lower(frm),
    case{'jpg','epg','bmp'}
        jpgcol=imread([DataProperties(j).PathName DataProperties(j).FileName]);
    case{'png'}
        [jpgcol,map,alpha]=imread([DataProperties(j).PathName DataProperties(j).FileName],'BackgroundColor','none');
    case{'gif'}
        jpgcol=imread([DataProperties(j).PathName DataProperties(j).FileName],1);
end
sz=size(jpgcol);
step=1;
jpgcol=jpgcol(1:step:sz(1),1:step:sz(2),:);
%col=double(jpgcol)/255;
col=jpgcol;

if ~isempty(DataProperties(j).GeoReferenceFile)


    txt=ReadTextFile(DataProperties(j).GeoReferenceFile);
    k=1;
    dx=str2double(txt{k});
    k=k+1;
    roty=str2double(txt{k});
    k=k+1;
    rotx=str2double(txt{k});
    k=k+1;
    dy=str2double(txt{k});
    k=k+1;
    x0=str2double(txt{k});
    k=k+1;
    y0=str2double(txt{k});
 
    a=dx*step;
    d=roty;
    b=rotx;
    e=dy*step;
    c=x0;
    f=y0;
    
    if rotx~=0 || roty~=0
        [x,y]=meshgrid(1:step:sz(2),1:step:sz(1));
        x=a*x0+b*y0+c;
        y=d*x0+e*y0+f;
    else
        % New: MvO
        x=x0:dx:x0+(sz(2)-1)*dx;
        y=y0:dy:y0+(sz(1)-1)*dy;
    end
    
    DataProperties(j).Type = 'GeoImage';
else
    [x,y]=meshgrid(1:step:sz(2),sz(1):-step:1);
    DataProperties(j).Type = 'Image';
end
 
z=zeros(size(x));

DataProperties(j).x    = x;
DataProperties(j).y    = y;
DataProperties(j).z    = z;
DataProperties(j).c    = col;
DataProperties(j).alpha = alpha;

DataProperties(j).TC='c';

clear x y z x y x0 y0 col jpgcol
