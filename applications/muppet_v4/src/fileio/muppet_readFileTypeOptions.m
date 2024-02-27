function xml=muppet_readFileTypeOptions(handles,filetype)

dr='c:\work\checkouts\OpenEarthTools\trunk\matlab\applications\muppet4\xml\filetypes\';
xml=xml2struct([dr filetype '.xml']);
