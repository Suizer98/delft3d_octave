function handles=muppet_readSubplotOptions(handles)

dr='c:\work\checkouts\OpenEarthTools\trunk\matlab\applications\muppet4\xml\subplotoptions\';
xml=xml2struct2([dr 'subplotoptions.xml']);
handles.subplotoption=xml.subplotoption;
