function plt=plotGeoImage(imname,geoname)
% Reads and plots georeferenced image
% e.g. plotGeoImage('delfland.jpg','delfland.jgw')

frm=imname(end-2:end);
switch lower(frm),
    case{'jpg','epg','bmp','tif'}
        jpgcol=imread(imname);
    case{'png'}
        jpgcol=imread(imname,'BackgroundColor','none');
    case{'gif'}
        jpgcol=imread(imname,1);
end
sz=size(jpgcol);

step=1;
jpgcol=jpgcol(1:step:sz(1),1:step:sz(2),:);
col=double(jpgcol)/255;

[x,y]=meshgrid(1:step:sz(2),1:step:sz(1));

txt=ReadTextFile(geoname);
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

x0=x;
y0=y;

x=a*x0+b*y0+c;
y=d*x0+e*y0+f;

z=zeros(size(x));
 
plt=surf(x,y,z,col);shading flat;

%%
function txt=ReadTextFile(FileName)
 
fid=fopen(FileName);

eof=0;

k=0;

while ~eof

    tx0=fgets(fid);
    
    if tx0==-1
        eof=1;
        break;
    end
    
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%q');
    else
        v0='';
    end
    if size(v0,1)>0
        if strcmp(tx0(1),'#')==0
            v=strread(tx0,'%q');
            nowords=size(v,1);
            for j=1:nowords
                k=k+1;
                txt{k}=v{j};
            end
            clear v;
        end
    end
end
 
fclose(fid);
