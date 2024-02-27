clear variables;close all;

mkdir('datatypes');

% Read all plot options
s=xml2struct('d:\checkouts\OpenEarthTools\trunk\matlab\applications\muppet_v4\src\newxml\plotoptions\plotoptions.xml','structuretype','short');
plotoption=s.plotoption;

% Read all plot option groups
dr='d:\checkouts\OpenEarthTools\trunk\matlab\applications\muppet_v4\src\newxml\plotoptiongroups\';
flist=dir([dr '*.xml']);
for ii=1:length(flist)
    s=xml2struct([dr flist(ii).name],'structuretype','short');
    plotoptiongroup(ii).plotoptiongroup.name=flist(ii).name(1:end-4);
    plotoptiongroup(ii).plotoptiongroup.plotoption=s.plotoption;
end

% Read all element groups
dr='d:\checkouts\OpenEarthTools\trunk\matlab\applications\muppet_v4\src\newxml\elementgroups\plotoptions\';
flist=dir([dr '*.xml']);
for ii=1:length(flist)
    s=xml2struct([dr flist(ii).name],'structuretype','short');
    elementgroup(ii).elementgroup.name=flist(ii).name(1:end-4);
    elementgroup(ii).elementgroup.element=s.element;
end

% Plot options
dr='d:\checkouts\OpenEarthTools\trunk\matlab\applications\muppet_v4\src\xml\datatypes\';
flist=dir([dr '*.xml']);
for ii=1:length(flist)
    s=[];
    s0=xml2struct([dr flist(ii).name]);
    s.longname.longname=s0.longname;
    for ip=1:length(s0.plot)
        s.plottype(ip).plottype.name.name=s0.plot(ip).plot.type;
        for ipr=1:length(s0.plot(ip).plot.plotroutine)
            s.plottype(ip).plottype.plotroutine(ipr).plotroutine.name.name=s0.plot(ip).plot.plotroutine(ipr).plotroutine.name;
            plotoption0=s0.plot(ip).plot.plotroutine(ipr).plotroutine.plotoption;
            n=0;
            nel=0;
            % First the plot options
            for ipl=1:length(plotoption0)
                plname=plotoption0(ipl).plotoption.name;
                igroup=0;
                if length(plname)>5
                    if strcmpi(plname(end-4:end),'group')
                        igroup=1;
                    end
                end
                if igroup
                    % Find plot option group
                    for j=1:length(plotoptiongroup)
                        if strcmpi(plotoptiongroup(j).plotoptiongroup.name,plname(1:end-5))
                            for k=1:length(plotoptiongroup(j).plotoptiongroup.plotoption)
                                n=n+1;
                                if isstruct(plotoptiongroup(j).plotoptiongroup.plotoption)
                                    s.plottype(ip).plottype.plotroutine(ipr).plotroutine.plotoption(n).plotoption.name.name=plotoptiongroup(j).plotoptiongroup.plotoption(k).plotoption;
                                else
                                    s.plottype(ip).plottype.plotroutine(ipr).plotroutine.plotoption(n).plotoption.name.name=plotoptiongroup(j).plotoptiongroup.plotoption;
                                end
                            end
                        end
                        
                    end
                    nel=nel+1;
                    s.plottype(ip).plottype.plotroutine(ipr).plotroutine.elementgroup(nel).elementgroup=plname(1:end-5);
                else
                    % Find individual plot option
                    n=n+1;
                    s.plottype(ip).plottype.plotroutine(ipr).plotroutine.plotoption(n).plotoption.name.name=plname;
                end
            end
        end
    end
    struct2xml(['datatypes/' flist(ii).name],s,'structuretype','short','includeattributes',0);
end
