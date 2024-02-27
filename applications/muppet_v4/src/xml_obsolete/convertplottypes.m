clear variables;close all;

dr='d:\checkouts\OpenEarthTools\trunk\matlab\applications\muppet_v4\src\xml\plottypes\';
flist=dir([dr '*.xml']);

mkdir('plottypes');

for ii=1:length(flist)
    s0=xml2struct([dr flist(ii).name]);
    s=s0.plottype.plottype;
    if isfield(s,'name')
    s=rmfield(s,'name');
    end
    for jj=1:length(s.option)
        s.subplotoption(jj).subplotoption.name=s.option(jj).option.name;
    end
    s=rmfield(s,'option');
    fname=flist(ii).name;
    struct2xml(['plottypes/' fname],s,'structuretype','short');
end
