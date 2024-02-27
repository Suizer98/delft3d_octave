function [x,y,z,col] = georeference_image(filename)
% v1.0 ??????? Ormondt
% v1.1 June-16 Nederhoff

% Example: how to use?
% figure; hold on;
% [xgeo, ygeo, zgeo, cgeo] = georeference_image('srilanka');
% surf(xgeo, ygeo, zgeo, cgeo); shading flat;
% freezeColors
% hpcolor = pcolor(X, Y, squeeze(u10(1,:,:))); shading flat;
% alpha(hpcolor,0.75);

% Get full filename
if exist([filename, '.jpg'])
    filename1 = [filename, '.jpg'];
    filename2 = [filename, '.jgw'];
elseif exist([filename, '.png'])
    filename1 = [filename, '.png'];
    filename2 = [filename, '.pgw'];
end
[jpgcol X] = imread(filename1);

% Other
sz = size(jpgcol);

step=1;
jpgcol=jpgcol(1:step:sz(1),1:step:sz(2),:);
col=double(jpgcol)/255;

[x,y]=meshgrid(1:step:sz(2),1:step:sz(1));

% Read text
fid=fopen(filename2);
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

end
