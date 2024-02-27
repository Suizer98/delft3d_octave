function linesKML(dr,fname,x1,y1,x2,y2,x3,y3,x4,y4,x5,y5,lookat)

xx{1}=x1;
xx{2}=x2;
xx{3}=x3;
xx{4}=x4;
xx{5}=x5;

yy{1}=y1;
yy{2}=y2;
yy{3}=y3;
yy{4}=y4;
yy{5}=y5;

styles={'blueLine','redLine','greenLine','yellowLine','whiteLine'};

fid=fopen([dr fname '.kml'],'wt');

fprintf(fid,'%s\n','<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2">');
fprintf(fid,'%s\n','<Document>');

fprintf(fid,'%s\n','<LookAt>');
fprintf(fid,'%s\n',['<longitude>' num2str(lookat.longitude) '</longitude>']);
fprintf(fid,'%s\n',['<latitude>' num2str(lookat.latitude) '</latitude>']);
fprintf(fid,'%s\n',['<altitude>' num2str(lookat.altitude) '</altitude>']);
fprintf(fid,'%s\n',['<range>' num2str(lookat.range) '</range>']);
fprintf(fid,'%s\n',['<tilt>' num2str(lookat.tilt) '</tilt>']);
fprintf(fid,'%s\n',['<heading>' num2str(lookat.heading) '</heading>']);
fprintf(fid,'%s\n','</LookAt>');

fprintf(fid,'%s\n','<ScreenOverlay id="legend">');
fprintf(fid,'%s\n','<Icon>');
fprintf(fid,'%s\n',['<href>legend.png</href>']);
fprintf(fid,'%s\n','</Icon>');
fprintf(fid,'%s\n','<overlayXY x="1" y="1" xunits="pixels" yunits="pixels"/>');
fprintf(fid,'%s\n','<screenXY x="10" y="10" xunits="pixels" yunits="pixels"/>');
fprintf(fid,'%s\n','<rotation>0</rotation>');
fprintf(fid,'%s\n','<size x="0" y="0" xunits="pixels" yunits="pixels"/>');
fprintf(fid,'%s\n','</ScreenOverlay>');

fprintf(fid,'%s\n','<Folder>');

fprintf(fid,'%s\n','<Style id="blueLine">');
fprintf(fid,'%s\n','<LineStyle>');
fprintf(fid,'%s\n','<width>2</width>');
fprintf(fid,'%s\n','<color>ffff0000</color>');
fprintf(fid,'%s\n','</LineStyle>');
fprintf(fid,'%s\n','</Style>');

fprintf(fid,'%s\n','<Style id="redLine">');
fprintf(fid,'%s\n','<LineStyle>');
fprintf(fid,'%s\n','<width>2</width>');
fprintf(fid,'%s\n','<color>ff0000ff</color>');
fprintf(fid,'%s\n','</LineStyle>');
fprintf(fid,'%s\n','</Style>');

fprintf(fid,'%s\n','<Style id="greenLine">');
fprintf(fid,'%s\n','<LineStyle>');
fprintf(fid,'%s\n','<width>2</width>');
fprintf(fid,'%s\n','<color>ff00ff00</color>');
fprintf(fid,'%s\n','</LineStyle>');
fprintf(fid,'%s\n','</Style>');

fprintf(fid,'%s\n','<Style id="yellowLine">');
fprintf(fid,'%s\n','<LineStyle>');
fprintf(fid,'%s\n','<width>2</width>');
fprintf(fid,'%s\n','<color>ffffff00</color>');
fprintf(fid,'%s\n','</LineStyle>');
fprintf(fid,'%s\n','</Style>');

fprintf(fid,'%s\n','<Style id="whiteLine">');
fprintf(fid,'%s\n','<LineStyle>');
fprintf(fid,'%s\n','<width>2</width>');
fprintf(fid,'%s\n','<color>ffffffff</color>');
fprintf(fid,'%s\n','</LineStyle>');
fprintf(fid,'%s\n','</Style>');

for k=1:5
    fprintf(fid,'%s\n','<Placemark>');
    fprintf(fid,'%s\n',['<styleUrl>#' styles{k} '</styleUrl>']);
    fprintf(fid,'%s\n','<LineString>');
    fprintf(fid,'%s\n','<coordinates>');
    for j=1:length(xx{k})
        fprintf(fid,'%s\n',[num2str(xx{k}(j),'%15.6f') ',' num2str(yy{k}(j),'%15.6f')]);
    end
    fprintf(fid,'%s\n','</coordinates>');
    fprintf(fid,'%s\n','</LineString>');
    fprintf(fid,'%s\n','</Placemark>');
end

fprintf(fid,'%s\n','</Folder>');
fprintf(fid,'%s\n','</Document>');
fprintf(fid,'%s\n','</kml>');

fclose(fid);

zip([dr fname '.zip'],{[dr fname '.kml'],[dr 'legend.png']});
movefile([dr fname '.zip'],[dr fname '.kmz']);
delete([dr fname '.kml']);
