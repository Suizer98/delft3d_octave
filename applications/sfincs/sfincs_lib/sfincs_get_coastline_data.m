function s=sfincs_get_coastline_data(xp,yp,xs,ys,cs,datasets,iopt)

for ii=1:length(datasets)
    datasets=filldatasets(datasets,ii,'zmin',-100000);
    datasets=filldatasets(datasets,ii,'zmax',100000);
    datasets=filldatasets(datasets,ii,'startdates',floor(now));
    datasets=filldatasets(datasets,ii,'searchintervals',-1e5);
    datasets=filldatasets(datasets,ii,'verticaloffset',0);
    datasets=filldatasets(datasets,ii,'verticaloffset',0);
    datasets=filldatasets(datasets,ii,'internaldiff',0);
    datasets=filldatasets(datasets,ii,'internaldiffusionrange',[-20000 20000]);
end

% if isempty(xs)
    [xs,ys]=spline2d(xs,ys);
% end

np=length(xp);
l1=5000;
l2=2000;
n=round((l1+l2)/10);
zdean=10;
xg=zeros(np,n+1);
yg=zeros(np,n+1);

for ip=1:np
    
    % Find nearest point on spline
    
    dst=sqrt((xs-xp(ip)).^2+(ys-yp(ip)).^2);
    inear=find(dst==min(dst));
    inear=inear(1);
    
    i1=max(1,inear-1);
    i2=min(length(xs),inear+1);
    dx=xs(i2)-xs(i1);
    dy=ys(i2)-ys(i1);
    phi=atan2(dy,dx)-0.5*pi;
    phi=mod(phi,2*pi);
    
    s.orientation(ip)=phi;
    
    x1=xp(ip)+l1*cos(s.orientation(ip));
    x2=xp(ip)-l2*cos(s.orientation(ip));
    y1=yp(ip)+l1*sin(s.orientation(ip));
    y2=yp(ip)-l2*sin(s.orientation(ip));
    dx=(x2-x1)/n;
    dy=(y2-y1)/n;
    xg(ip,:)=x1:dx:x2;
    yg(ip,:)=y1:dy:y2;
    
    s.orientation(ip)=mod(90-s.orientation(ip)*180/pi,360); % nautical degrees
end

handles=getHandles;
zg=zeros(size(xg));
modeloffset=0;
overwrite=1;
gridtype='unstructured';
intdif=0;
zg=ddb_interpolateBathymetry2(handles.bathymetry,datasets,xg,yg,zg,modeloffset,overwrite,gridtype, ...
    intdif,cs,'dmin',20);

for ip=1:np
    % Initialize
    s.slope(ip)=0.01;
    s.dean(ip)=0.05;
    s.reef_width(ip)=1000;
    s.reef_height(ip)=-1;
end
        
switch iopt
    case 1,2;
        % Plain or natural sloping beach (Dean profile)
        for ip=1:np
            
            x=squeeze(xg(ip,:));
            y=squeeze(yg(ip,:));
            z=squeeze(zg(ip,:));
            i1=find(z>=-zdean,1,'first');
            i2=find(z>=0,1,'first');
            dst=sqrt((x(i2)-x(i1)).^2+(y(i2)-y(i1)).^2);
            s.slope(ip)=zdean/dst;
            s.dean(ip)=zdean/dst^(2/3);
            s.type(ip)=iopt;
%             x=x(i1:i2);
%             y=y(i1:i2);
%             z=z(i1:i2);
%             x=fliplr(x);
%             y=fliplr(y);
%             z=fliplr(z);
%             pd=pathdistance(x,y);
%             figure(100);
%             plot(pd,z);hold on;
%             zd=-s.dean(ip)*pd.^(2/3);
%             plot(pd,zd,'r');hold on;
%            shite=1;
            
        end
end

%% Fill datasets
function datasets=filldatasets(datasets,ii,var,val)
if ~isfield(datasets(ii),var)
    datasets(ii).(var)=val;
elseif isempty(datasets(ii).(var))
    datasets(ii).(var)=val;
end
