function profileKML(fname,x0,y0,x1,y1,varargin)

dr='.\';
r=100;
c=[0 1 0;0 0 1;1 0 0];
transp=1;
kmlkmz='kml';
levs=[];

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case {'directory'}
                dr=varargin{i+1};
            case {'radius'}
                r=varargin{i+1};
            case {'zfac'}
                zfac=varargin{i+1};
            case {'colormap','color'}
                c=varargin{i+1};
            case {'transparency'}
                transp=varargin{i+1};
            case {'levels'}
                levs=varargin{i+1};
            case {'clim'}
                clim=varargin{i+1};
            case {'kmz'}
                if varargin{i+1}
                    kmlkmz='kmz';
                end
        end
    end
end

fid=fopen([dr fname '.kml'],'wt');

fprintf(fid,'%s\n','<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2">');
fprintf(fid,'%s\n','');

fprintf(fid,'%s\n','<Folder>');

fprintf(fid,'%s\n',' ');

fprintf(fid,'%s\n',['  <Style id="blueLine">']);
fprintf(fid,'%s\n','    <LineStyle>');
fprintf(fid,'%s\n','      <width>1.5</width>');
fprintf(fid,'%s\n',['      <color>ffff0000</color>']);
fprintf(fid,'%s\n','    </LineStyle>');
fprintf(fid,'%s\n','  </Style>');
fprintf(fid,'%s\n',' ');

for j=1:length(x0)

        fprintf(fid,'%s\n','  <Placemark>');
        fprintf(fid,'%s\n',['    <styleUrl>#blueLine</styleUrl>']);
        fprintf(fid,'%s\n','    <LineString>');
        fprintf(fid,'%s\n','      <coordinates>');           
        fprintf(fid,'%s\n',['        ' num2str(x0(j),'%15.6f') ',' num2str(y0(j),'%15.6f')]);
        fprintf(fid,'%s\n',['        ' num2str(x1(j),'%15.6f') ',' num2str(y1(j),'%15.6f')]);
        fprintf(fid,'%s\n','      </coordinates>');
        fprintf(fid,'%s\n','    </LineString>');
        fprintf(fid,'%s\n','  </Placemark>');
        fprintf(fid,'%s\n',' ');

end

fprintf(fid,'%s\n','</Folder>');
fprintf(fid,'%s\n',' ');
fprintf(fid,'%s\n','</kml>');

fclose(fid);

if strcmpi(kmlkmz,'kmz')
    zip([dr fname '.zip'],[dr fname '.kml']);
    movefile([dr fname '.zip'],[dr fname '.kmz']);
    delete([dr fname '.kml']);    
end

