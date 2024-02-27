function quiverKML(fname,x,y,u,v,varargin)

dr='.\';
c=[0 1 0;0 0 1;1 0 0];
transp=1;
kmlkmz='kml';
levs=[];
url='';
overlayfile='';
lookat=[];
t=0;
anim=0;
thinning=1;
thinningX=[];
thinningY=[];
scalefactor=1;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case {'time'}
                t=varargin{i+1};
                anim=1;
            case {'directory'}
                dr=varargin{i+1};
            case {'colormap','color'}
                c=varargin{i+1};
            case {'transparency'}
                transp=varargin{i+1};
            case {'levels'}
                levs=varargin{i+1};
            case {'url'}
                url=varargin{i+1};
            case {'screenoverlay'}
                overlayfile=varargin{i+1};
            case {'kmz'}
                if varargin{i+1}
                    kmlkmz='kmz';
                end
            case {'lookat'}
                lookat=varargin{i+1};
            case {'thinning'}
                thinning=varargin{i+1};
            case {'thinningx'}
                thinningX=varargin{i+1};
            case {'thinningy'}
                thinningY=varargin{i+1};
            case {'scalefactor'}
                scalefactor=varargin{i+1};
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

c=makeColorMap(c,length(levs));

fid=fopen([dr fname '.kml'],'wt');

fprintf(fid,'%s\n','<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2">');

fprintf(fid,'%s\n','<Document>');

for ic=1:size(c,1)
    styleName{ic}=['style' num2str(ic,'%0.2i')];
end

for ic=1:size(c,1)
    
    opstr=lower(dec2hex(round(255*transp)));
    if length(opstr)==1
        opstr=['0' opstr];
    end
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
    
    fprintf(fid,'%s\n',['<Style id="' styleName{ic} '">']);
    fprintf(fid,'%s\n','<LineStyle>');
    fprintf(fid,'%s\n','<width>1.5</width>');
    fprintf(fid,'%s\n',['<color>ff' bstr gstr rstr '</color>']);
    fprintf(fid,'%s\n','</LineStyle>');
    fprintf(fid,'%s\n','</Style>');
end

if ~isempty(lookat)
    fprintf(fid,'%s\n','<LookAt>');
    fprintf(fid,'%s\n',['<longitude>' num2str(lookat.longitude) '</longitude>']);
    fprintf(fid,'%s\n',['<latitude>' num2str(lookat.latitude) '</latitude>']);
    fprintf(fid,'%s\n',['<altitude>' num2str(lookat.altitude) '</altitude>']);
    fprintf(fid,'%s\n',['<range>' num2str(lookat.range) '</range>']);
    fprintf(fid,'%s\n',['<tilt>' num2str(lookat.tilt) '</tilt>']);
    fprintf(fid,'%s\n',['<heading>' num2str(lookat.heading) '</heading>']);
    fprintf(fid,'%s\n','</LookAt>');
end

if ~isempty(overlayfile)
    if ~isempty(url)
        url=[url '/'];
    end
    [pathstr,namestr,ext] = fileparts(overlayfile);
    fprintf(fid,'%s\n','<ScreenOverlay id="colorbar">');
    fprintf(fid,'%s\n','<Icon>');
    fprintf(fid,'%s\n',['<href>' url namestr ext '</href>']);
    fprintf(fid,'%s\n','</Icon>');
    fprintf(fid,'%s\n','<overlayXY x="1" y="1" xunits="pixels" yunits="pixels"/>');
    fprintf(fid,'%s\n','<screenXY x="10" y="10" xunits="pixels" yunits="pixels"/>');
    fprintf(fid,'%s\n','<rotation>0</rotation>');
    fprintf(fid,'%s\n','<size x="0" y="0" xunits="pixels" yunits="pixels"/>');
    fprintf(fid,'%s\n','</ScreenOverlay>');
end

x=reshape(x,[size(x,1)*size(y,2) 1]);
y=reshape(y,[size(y,1)*size(y,2) 1]);

y=merc(y);

xp00(1)=0;
yp00(1)=0;
xp00(2)=1;
yp00(2)=0;
xp00(3)=0.7;
yp00(3)=0.2;
xp00(4)=1;
yp00(4)=0;
xp00(5)=0.7;
yp00(5)=-0.2;
ang00=atan2(yp00,xp00);
dst00=sqrt(xp00.^2+yp00.^2);
dst00=dst00*scalefactor;

for it=1:length(t)
    
    disp(['Processing ' num2str(it) ' of ' num2str(length(t)) ' ...']);
    
    fprintf(fid,'%s\n','<Folder>');
    
%     if anim
%         dt=t(2)-t(1);
%         fprintf(fid,'%s\n','<TimeSpan>');
%         fprintf(fid,'%s\n',['<begin>' datestr(t(it),'yyyy-mm-ddTHH:MM:SSZ') '</begin>']);
%         fprintf(fid,'%s\n',['<end>' datestr(t(it)+dt+0.0001,'yyyy-mm-ddTHH:MM:SSZ') '</end>']);
%         fprintf(fid,'%s\n','</TimeSpan>');
%     end
    
    uu=squeeze(u(it,:,:));
    vv=squeeze(v(it,:,:));
    
    uu=reshape(uu,[size(uu,1)*size(uu,2) 1]);
    vv=reshape(vv,[size(vv,1)*size(vv,2) 1]);

    % Get rid of NaNs and zero velocities
    xx=x;
    yy=y;

    vel=sqrt(uu.^2+vv.^2);    
    uu(vel==0)=NaN;
    vv(vel==0)=NaN;        
    xx(isnan(uu))=NaN;
    yy(isnan(uu))=NaN;
    xx=xx(~isnan(xx));
    yy=yy(~isnan(yy));
    uu=uu(~isnan(uu));
    vv=vv(~isnan(vv));

    nvec=length(uu);

    % Compute velocity magnitude and angle of each vector
    vel=sqrt(uu.^2+vv.^2);    
    ang=atan2(vv,uu);

    % Multiply unit vector with velocity magnitude
    dst0=vel*dst00;

    % Rotate vector with velocity angle
    ang=repmat(ang,1,5);
    ang=ang+repmat(ang00,nvec,1);    
    xp=dst0.*cos(ang);
    yp=dst0.*sin(ang);

    % Translate vector
    xp=xp+repmat(xx,1,5);
    yp=yp+repmat(yy,1,5);

    yp=invmerc(yp);       

    % Now sort by level
    for k=1:length(levs)
        
        if k==1
            inlev=find(vel<levs(k+1));
        elseif k<length(levs)
            inlev=find(vel>=levs(k) & vel<levs(k+1));
        else
            inlev=find(vel>=levs(k));
        end
        
        if ~isempty(inlev)
        
            xp1=xp(inlev,:);
            yp1=yp(inlev,:);
            fprintf(fid,'%s\n','<Placemark>');
            fprintf(fid,'%s\n',['<styleUrl>#' styleName{k} '</styleUrl>']);
            fprintf(fid,'%s\n','<MultiGeometry>');
            for j=1:size(xp1,1)
                fprintf(fid,'%s\n','<LineString>');
                fprintf(fid,'%s\n','<coordinates>');
                vals=[xp1(j,:);yp1(j,:);zeros(1,5)];
                fprintf(fid,'%5.5f,%5.5f,%i\n',vals);
                fprintf(fid,'%s\n','</coordinates>');
                fprintf(fid,'%s\n','</LineString>');
            end
            fprintf(fid,'%s\n','</MultiGeometry>');
            fprintf(fid,'%s\n','</Placemark>');
        end                                    
    end
    fprintf(fid,'%s\n','</Folder>');
end
fprintf(fid,'%s\n','</Document>');
fprintf(fid,'%s\n','</kml>');

fclose(fid);

if strcmpi(kmlkmz,'kmz')
    if ~isempty(overlayfile)
        zip([dr fname '.zip'],{[dr fname '.kml'],[dr overlayfile]});
    else
        zip([dr fname '.zip'],[dr fname '.kml']);
    end
    movefile([dr fname '.zip'],[dr fname '.kmz']);
    delete([dr fname '.kml']);
end

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
