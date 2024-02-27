clear variables;close all;

dr='d:\checkouts\OpenEarthTools\trunk\matlab\applications\muppet_v4\src\xml\filetypes\';
flist=dir([dr '*.xml']);

mkdir('filetypes');

for ii=1:length(flist)
    s0=xml2struct([dr flist(ii).name]);
    s=s0;
    s=rmfield(s,'name');
    for jj=1:length(s0.option)
        s.dataproperty(jj).dataproperty.name=s0.option(jj).option.name;
    end
    s=rmfield(s,'option');
    n=0;
    for jj=1:length(s.dataproperty)
        if exist(['d:\checkouts\OpenEarthTools\trunk\matlab\applications\muppet_v4\src\newxml\elementgroups\dataproperties\' s.dataproperty(jj).dataproperty.name '.xml'],'file')
            n=n+1;
            s.elementgroup(n).elementgroup=s.dataproperty(jj).dataproperty.name;
        end
    end
    fname=flist(ii).name;
    struct2xml(['filetypes/' fname],s,'structuretype','short');
end
