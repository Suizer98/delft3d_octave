function handles=muppet_readDataElements(handles)

dr='c:\work\checkouts\OpenEarthTools\trunk\matlab\applications\muppet4\xml\dataelements\';

flist=dir([dr '*.xml']);
for ii=1:length(flist)
    xml=xml2struct2([dr flist(ii).name]);
    handles.dataelement(ii).dataelement.name=flist(ii).name(1:end-4);
    % Compute width and height
    width=0;
    height=0;
    for jj=1:length(xml.element)
        pos=str2num(xml.element(jj).element.position);
        width=max(width,pos(1)+pos(3));
        height=max(height,pos(2)+pos(4));
    end
    handles.dataelement(ii).dataelement.width=width;
    handles.dataelement(ii).dataelement.height=height;
    handles.dataelement(ii).dataelement.element=xml.element;
end
