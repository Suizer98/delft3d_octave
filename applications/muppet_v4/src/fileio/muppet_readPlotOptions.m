function handles=muppet_readPlotOptions(handles)

dr='c:\work\checkouts\OpenEarthTools\trunk\matlab\applications\muppet4\xml\plotoptions\';
xml=xml2struct2([dr 'plotoptions.xml']);
handles.plotoption=xml.plotoption;
