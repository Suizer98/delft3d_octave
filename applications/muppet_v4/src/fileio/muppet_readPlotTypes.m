function handles=muppet_readPlotTypes(handles)

dr='c:\work\checkouts\OpenEarthTools\trunk\matlab\applications\muppet4\xml\plottypes\';

flist=dir([dr '*.xml']);
for ii=1:length(flist)
    xml=xml2struct2([dr flist(ii).name]);
    handles.plottype(ii).plottype=xml;
end
