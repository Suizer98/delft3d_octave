function writeAnimKML(figdr,url,name,xlim,ylim,t)

dt=t(2)-t(1);

for it=1:length(t)
    kml.Folder(it).name='Overlays with TimeSpans';
    kml.Folder(it).GroundOverlay.name=name;
    kml.Folder(it).GroundOverlay.timeSpan.begin=datestr(t(it),'yyyy-mm-ddTHH:MM:SSZ');
    kml.Folder(it).GroundOverlay.timeSpan.end=datestr(t(it)+dt,'yyyy-mm-ddTHH:MM:SSZ');
%     kml.Folder(it).GroundOverlay.timeStamp.when=datestr(t(it),'yyyy-mm-ddTHH:MM:SSZ');
%     kml.Folder(it).GroundOverlay.timeStamp.end=datestr(t(it)+dt,'yyyy-mm-ddTHH:MM:SSZ');
    kml.Folder(it).GroundOverlay.Icon.href=[url name '.' datestr(t(it),'yyyymmdd.HHMMSS') '.png'];
    kml.Folder(it).GroundOverlay.LatLonBox.north=num2str(ylim(2));
    kml.Folder(it).GroundOverlay.LatLonBox.south=num2str(ylim(1));
    kml.Folder(it).GroundOverlay.LatLonBox.east=num2str(xlim(2));
    kml.Folder(it).GroundOverlay.LatLonBox.west=num2str(xlim(1));
end
    
xml_save([figdr name],kml,'off');

movefile([figdr name '.xml'],[figdr name '.kml']);
findreplace([figdr name '.kml'],'<root>','<kml xmlns="http://earth.google.com/kml/2.2">');
findreplace([figdr name '.kml'],'</root>','</kml>');
