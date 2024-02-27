function vectorXML(fname,x,y,u,v,varargin)

c=[0 0 1 0;0.5 0 0 1;1 1 0 0];

dr='.\';
overlayfile='';
lookat=[];
t=0;
thinning=1;
thinningX=[];
thinningY=[];
polygon=[];
scalefactor=0.001;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case {'time'}
                t=varargin{i+1};
            case {'directory'}
                dr=varargin{i+1};
            case {'screenoverlay'}
                overlayfile=varargin{i+1};
            case {'lookat'}
                lookat=varargin{i+1};
            case {'thinning'}
                thinning=varargin{i+1};
            case {'thinningx'}
                thinningX=varargin{i+1};
            case {'thinningy'}
                thinningY=varargin{i+1};
            case {'polygon'}
                polygon=varargin{i+1};
            case {'scalefactor'}
                scalefactor=varargin{i+1};
            case {'levels'}
                levs=varargin{i+1};
            case {'colormap','color'}
                c=varargin{i+1};
        end
    end
end

thin1=thinning;
thin2=thinning;
if ~isempty(thinningX)
    thin2=thinningX;
end
if ~isempty(thinningY)
    thin1=thinningY;
end

x=x(1:thin1:end,1:thin2:end);
y=y(1:thin1:end,1:thin2:end);
u=u(:,1:thin1:end,1:thin2:end);
v=v(:,1:thin1:end,1:thin2:end);

n1=size(x,1);
n2=size(x,2);

x=reshape(x,[1 n1*n2]);
y=reshape(y,[1 n1*n2]);

if ~isempty(polygon)
    xp=squeeze(polygon(:,1));
    yp=squeeze(polygon(:,2));
    inpol=inpolygon(x,y,xp,yp);
    x(~inpol)=NaN;
    y(~inpol)=NaN;
end

% Find cells where velocity exceeds 0.1 m/s at least once
umag=sqrt(u.^2+v.^2);
umag=nanmax(umag,1);
umag=squeeze(umag);
umag=reshape(umag,[1 n1*n2]);
umag(isnan(umag))=0;

x(umag<0.1)=NaN;

isn=isnan(x);

x=x(~isn);
y=y(~isn);

mdl.scalefactor.scalefactor.value=scalefactor;
mdl.scalefactor.scalefactor.ATTRIBUTES.type.value='real';

if ~isempty(overlayfile)
    mdl.screenoverlay.screenoverlay.value=overlayfile;
    mdl.screenoverlay.screenoverlay.ATTRIBUTES.type.value='char';
end

%% Styles
c=makeColorMap(c,length(levs));
for ic=1:length(levs)
    rstr=lower(dec2hex(round(255*c(ic,1))));
    if length(rstr)==1
        rstr=['0' rstr];
    end
    gstr=lower(dec2hex(round(255*c(ic,2))));
    if length(gstr)==1
        gstr=['0' gstr];
    end
    bstr=lower(dec2hex(round(255*c(ic,3))));
    if length(bstr)==1
        bstr=['0' bstr];
    end
    mdl.styles.styles.style(ic).style.color.color.value=['ff' bstr gstr rstr];
    mdl.styles.styles.style(ic).style.color.color.ATTRIBUTES.type.value='char';
end

%% Levels
mdl.cmin.cmin.value=levs(1);
mdl.cmin.cmin.ATTRIBUTES.type.value='real';
mdl.cmax.cmax.value=levs(end);
mdl.cmax.cmax.ATTRIBUTES.type.value='real';

mdl.x.x.value=x;
mdl.x.x.ATTRIBUTES.type.value='real';
mdl.x.x.FORMAT='%0.5f';
mdl.y.y.value=y;
mdl.y.y.ATTRIBUTES.type.value='real';
mdl.y.y.FORMAT='%0.5f';

for it=1:length(t)
    
    uu=squeeze(u(it,:,:));
    vv=squeeze(v(it,:,:));
    uu=reshape(uu,[1 n1*n2]);
    vv=reshape(vv,[1 n1*n2]);
    
    uu=uu(~isn);
    vv=vv(~isn);

    mdl.times.times.time(it).time.u.u.value=uu;
    mdl.times.times.time(it).time.u.u.ATTRIBUTES.type.value='real';
    mdl.times.times.time(it).time.u.u.FORMAT='%0.2f';
    mdl.times.times.time(it).time.v.v.value=vv;
    mdl.times.times.time(it).time.v.v.ATTRIBUTES.type.value='real';
    mdl.times.times.time(it).time.v.v.FORMAT='%0.2f';

end

struct2xml([dr fname],mdl,'includeattributes',1,'structuretype','long');

%%
function rgb=makeColorMap(clmap,n)

if size(clmap,2)==4
    x=clmap(:,1);
    r=clmap(:,2);
    g=clmap(:,3);
    b=clmap(:,4);
else
    x=0:1/(size(clmap,1)-1):1;
    r=clmap(:,1);
    g=clmap(:,2);
    b=clmap(:,3);
end

for i=2:size(x,1)
    x(i)=max(x(i),x(i-1)+1.0e-6);
end

x1=0:(1/(n-1)):1;

r1=interp1(x,r,x1);
g1=interp1(x,g,x1);
b1=interp1(x,b,x1);

rgb(:,1)=r1;
rgb(:,2)=g1;
rgb(:,3)=b1;

rgb=max(0,rgb);
rgb=min(1,rgb);
