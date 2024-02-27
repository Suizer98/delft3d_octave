function contourfKML(fname,x,y,z,varargin)

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
        end
    end
end

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
    fprintf(fid,'%s\n',['<color>00' bstr gstr rstr '</color>']);
    fprintf(fid,'%s\n','</LineStyle>');
    fprintf(fid,'%s\n','<PolyStyle>');
    fprintf(fid,'%s\n',['<color>' opstr bstr gstr rstr '</color>']);
    fprintf(fid,'%s\n','</PolyStyle>');
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

for it=1:length(t)
    
%    disp(['Processing ' num2str(it) ' of ' num2str(length(t)) ' ...']);
    
    fprintf(fid,'%s\n','<Folder>');
    
    if anim
        dt=t(2)-t(1);
        [innerisland,outerisland,v]=getIslands(x,y,squeeze(z(it,:,:)),levs);
%         fprintf(fid,'%s\n','<TimeSpan>');
%         fprintf(fid,'%s\n',['<begin>' datestr(t(it),'yyyy-mm-ddTHH:MM:SSZ') '</begin>']);
%         fprintf(fid,'%s\n',['<end>' datestr(t(it)+dt+0.0001,'yyyy-mm-ddTHH:MM:SSZ') '</end>']);
%         fprintf(fid,'%s\n','</TimeSpan>');
    else
        [innerisland,outerisland,v]=getIslands(x,y,z,levs);
    end
   
    for i=1:length(outerisland)
        
        st=styleName{end};
        for k=1:length(levs)
            if v(i)<=levs(k)
                st=styleName{k};
                break
            end
        end
        
        fprintf(fid,'%s\n','<Placemark>');
        fprintf(fid,'%s\n',['<name>' num2str(i,'%0.5i') '</name>']);
        fprintf(fid,'%s\n',['<styleUrl>#' st '</styleUrl>']);
        
        deref=5;
        
        fprintf(fid,'%s\n','<Polygon>');
        fprintf(fid,'%s\n','<altitudeMode>clampedtoground</altitudeMode>');
        fprintf(fid,'%s\n','<outerBoundaryIs>');
        fprintf(fid,'%s\n','<LinearRing>');
        fprintf(fid,'%s\n','<coordinates>');
        zer=zeros(size(outerisland{i}.x(1:deref:end)));
        vals=[outerisland{i}.x(1:deref:end) outerisland{i}.y(1:deref:end) zer]';
        fprintf(fid,'%3.6f,%3.6f,%i\n',vals);
        fprintf(fid,'%s\n','</coordinates>');
        fprintf(fid,'%s\n','</LinearRing>');
        fprintf(fid,'%s\n','</outerBoundaryIs>');
        for j=1:length(innerisland{i})
        fprintf(fid,'%s\n','<innerBoundaryIs>');
        fprintf(fid,'%s\n','<LinearRing>');
        fprintf(fid,'%s\n','<coordinates>');
        zer=zeros(size(innerisland{i}(j).x(1:deref:end)));
        vals=[innerisland{i}(j).x(1:deref:end) innerisland{i}(j).y(1:deref:end) zer]';
        fprintf(fid,'%3.6f,%3.6f,%i\n',vals);
        fprintf(fid,'%s\n','</coordinates>');
        fprintf(fid,'%s\n','</LinearRing>');
        fprintf(fid,'%s\n','</innerBoundaryIs>');
        end
        fprintf(fid,'%s\n','</Polygon>');
    fprintf(fid,'%s\n','</Placemark>');
    end
    fprintf(fid,'%s\n','</Folder>');
end
fprintf(fid,'%s\n','</Document>');
fprintf(fid,'%s\n','</kml>');

fclose(fid);

if strcmpi(kmlkmz,'kmz')
    if ~isempty(overlayfile)
        zip([dr fname '.zip'],{[dr fname '.kml'],overlayfile});
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
