function handles=muppet_readDataTypes(handles)

dr='c:\work\checkouts\OpenEarthTools\trunk\matlab\applications\muppet4\xml\datatypes\';
flist=dir([dr '*.xml']);
for ii=1:length(flist)
    xml=xml2struct2([dr flist(ii).name]);
    handles.datatype(ii).datatype=xml;
    handles.datatypenames{ii}=flist(ii).name(1:end-4);
end
