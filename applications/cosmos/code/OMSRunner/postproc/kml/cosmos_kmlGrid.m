function cosmos_kmlGrid(fname,x,y,varargin)

dr='.\';
kmlkmz='kmz';
overlayfile='';
lookat=[];
clr=[];
url='';

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case {'color'}
                clr=varargin{i+1};
            case {'dir'}
                dr=varargin{i+1};
            case {'kml'}
                kmlkmz='kml';
            case {'kmz'}
                kmlkmz='kmz';
            case {'overlay'}
                overlayfile=varargin{i+1};
        end
    end
end

dx=sqrt((x(2:end,2:end)-x(1:end-1,1:end-1)).^2+(y(2:end,2:end)-y(1:end-1,1:end-1)).^2);
dx=dx(~isnan(dx));
dx=mean(mean(dx));
ndec=ceil(-log10(dx))+2;

npol=0;
for i=1:size(x,1)
    for j=1:size(x,2)
        % Check when to start a new segment
        if j==1 && ~isnan(x(i,j))
            % First point in grid, new segment
            npol=npol+1;
            k=1;
            xp{npol}(k)=x(i,j);
            yp{npol}(k)=y(i,j);
        elseif j==1
            % First grid point but it's a nan
        elseif ~isnan(x(i,j)) && isnan(x(i,j-1))
            % New segment
            npol=npol+1;
            k=1;
            xp{npol}(k)=x(i,j);
            yp{npol}(k)=y(i,j);
        elseif ~isnan(x(i,j))
            % Existing segment segment
            k=k+1;            
            xp{npol}(k)=x(i,j);
            yp{npol}(k)=y(i,j);
        end        
    end
end

% And now the other way
for j=1:size(x,2)
    for i=1:size(x,1)
        % Check when to start a new segment
        if i==1 && ~isnan(x(i,j))
            % First point in grid, new segment
            npol=npol+1;
            k=1;
            xp{npol}(k)=x(i,j);
            yp{npol}(k)=y(i,j);
        elseif i==1
            % First grid point but it's a nan
        elseif ~isnan(x(i,j)) && isnan(x(i-1,j))
            % New segment
            npol=npol+1;
            k=1;
            xp{npol}(k)=x(i,j);
            yp{npol}(k)=y(i,j);
        elseif ~isnan(x(i,j))
            % Existing segment segment
            k=k+1;            
            xp{npol}(k)=x(i,j);
            yp{npol}(k)=y(i,j);
        end        
    end
end

fid=fopen([fname '.kml'],'wt');

fprintf(fid,'%s\n','<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2">');

fprintf(fid,'%s\n','<Document>');

if isempty(clr)
    clr=[0 0 1];
end

rstr=lower(dec2hex(round(255*clr(1))));
if length(rstr)==1
    rstr=['0' rstr];
end
gstr=lower(dec2hex(round(255*clr(2))));
if length(gstr)==1
    gstr=['0' gstr];
end
bstr=lower(dec2hex(round(255*clr(3))));
if length(bstr)==1
    bstr=['0' bstr];
end

fprintf(fid,'%s\n','<Style id="style">');
fprintf(fid,'%s\n','<LineStyle>');
fprintf(fid,'%s\n','<width>1.5</width>');
fprintf(fid,'%s\n',['<color>ff' bstr gstr rstr '</color>']);
fprintf(fid,'%s\n','</LineStyle>');
fprintf(fid,'%s\n','</Style>');

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
    fprintf(fid,'%s\n','<ScreenOverlay id="overlay">');
    fprintf(fid,'%s\n','<Icon>');
    fprintf(fid,'%s\n',['<href>' url namestr ext '</href>']);
    fprintf(fid,'%s\n','</Icon>');
    fprintf(fid,'%s\n','<overlayXY x="1" y="1" xunits="pixels" yunits="pixels"/>');
    fprintf(fid,'%s\n','<screenXY x="10" y="10" xunits="pixels" yunits="pixels"/>');
    fprintf(fid,'%s\n','<rotation>0</rotation>');
    fprintf(fid,'%s\n','<size x="0" y="0" xunits="pixels" yunits="pixels"/>');
    fprintf(fid,'%s\n','</ScreenOverlay>');
end
    
fprintf(fid,'%s\n','<Folder>');

fmt=['%3.' num2str(ndec) 'f,%3.' num2str(ndec) 'f,%i\n'];
for i=1:length(xp)    
    fprintf(fid,'%s\n','<Placemark>');
    fprintf(fid,'%s\n',['<styleUrl>#style</styleUrl>']);
    fprintf(fid,'%s\n','<LineString>');
    fprintf(fid,'%s\n','<coordinates>');
    zer=zeros(size(xp{i}'))+0;
    vals=[xp{i}' yp{i}' zer]';
    fprintf(fid,fmt,vals);
    fprintf(fid,'%s\n','</coordinates>');
    fprintf(fid,'%s\n','</LineString>');
    fprintf(fid,'%s\n','</Placemark>');
end
fprintf(fid,'%s\n','</Folder>');

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
