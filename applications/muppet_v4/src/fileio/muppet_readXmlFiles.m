function handles=muppet_readXmlFiles(handles)

dr=handles.xmldir;
% dr='d:\checkouts\OpenEarthTools\trunk\matlab\applications\muppet_v4\src\newxml\';

%% Data types
flist=dir([dr 'datatypes' filesep '*.xml']);
for ii=1:length(flist)
    xml=xml2struct([dr 'datatypes' filesep flist(ii).name]);
    handles.datatype(ii).datatype=xml;
    handles.datatype(ii).datatype.name=flist(ii).name(1:end-4);
    handles.datatypenames{ii}=flist(ii).name(1:end-4);
    % Fix element groups (if there's only one element group, it is read as a string...)
    for ipl=1:length(handles.datatype(ii).datatype.plottype)
        for ipr=1:length(handles.datatype(ii).datatype.plottype(ipl).plottype.plotroutine)
            if isfield(handles.datatype(ii).datatype.plottype(ipl).plottype.plotroutine(ipr).plotroutine,'elementgroup')
                if ischar(handles.datatype(ii).datatype.plottype(ipl).plottype.plotroutine(ipr).plotroutine.elementgroup)
                    str=handles.datatype(ii).datatype.plottype(ipl).plottype.plotroutine(ipr).plotroutine.elementgroup;
                    handles.datatype(ii).datatype.plottype(ipl).plottype.plotroutine(ipr).plotroutine.elementgroup=[];
                    handles.datatype(ii).datatype.plottype(ipl).plottype.plotroutine(ipr).plotroutine.elementgroup.elementgroup=str;
                end
            end
        end
    end
end

%% Data properties
xml=xml2struct([dr 'dataproperties' filesep 'dataproperties.xml']);
handles.dataproperty=xml.dataproperty;
for jj=1:length(handles.dataproperty)
    handles.datapropertynames{jj}=handles.dataproperty(jj).dataproperty.name;
end
% And now the plot option element groups
flist=dir([dr 'elementgroups' filesep 'dataproperties' filesep '*.xml']);
for ii=1:length(flist)
    handles.datapropertyelementgroup(ii).datapropertyelementgroup=xml2struct([dr 'elementgroups' filesep 'dataproperties' filesep flist(ii).name]);
    handles.datapropertyelementgroup(ii).datapropertyelementgroup.name=flist(ii).name(1:end-4);
    handles.datapropertyelementgroupnames{ii}=flist(ii).name(1:end-4);
    % Determine total width and height of element group
    wdt=0;
    hgt=0;
    for jj=1:length(handles.datapropertyelementgroup(ii).datapropertyelementgroup.element)
        pos=str2num(handles.datapropertyelementgroup(ii).datapropertyelementgroup.element(jj).element.position);
        wdt=max(wdt,pos(1)+pos(3));
        hgt=max(hgt,pos(2)+pos(4));        
    end
    handles.datapropertyelementgroup(ii).datapropertyelementgroup.width=wdt;
    handles.datapropertyelementgroup(ii).datapropertyelementgroup.height=hgt;
end

%% Plot Options
xml=xml2struct([dr 'plotoptions' filesep 'plotoptions.xml']);
handles.plotoption=xml.plotoption;
for jj=1:length(handles.plotoption)
    handles.plotoptionnames{jj}=handles.plotoption(jj).plotoption.name;
end
% And now the plot option element groups
flist=dir([dr 'elementgroups' filesep 'plotoptions' filesep '*.xml']);
for ii=1:length(flist)
    handles.plotoptionelementgroup(ii).plotoptionelementgroup=xml2struct([dr 'elementgroups' filesep 'plotoptions' filesep flist(ii).name]);
    handles.plotoptionelementgroup(ii).plotoptionelementgroup.name=flist(ii).name(1:end-4);
    handles.plotoptionelementgroupnames{ii}=flist(ii).name(1:end-4);
    % Determine total width and height of element group
    wdt=0;
    hgt=0;
    for jj=1:length(handles.plotoptionelementgroup(ii).plotoptionelementgroup.element)
        pos=str2num(handles.plotoptionelementgroup(ii).plotoptionelementgroup.element(jj).element.position);
        wdt=max(wdt,pos(1)+pos(3));
        hgt=max(hgt,pos(2)+pos(4));        
    end
    handles.plotoptionelementgroup(ii).plotoptionelementgroup.width=wdt;
    handles.plotoptionelementgroup(ii).plotoptionelementgroup.height=hgt;
end

%% Subplot Options
xml=xml2struct([dr 'subplotoptions' filesep 'subplotoptions.xml']);
handles.subplotoption=xml.subplotoption;

%% Figure Options
xml=xml2struct([dr 'figureoptions' filesep 'figureoptions.xml']);
handles.figureoption=xml.figureoption;

%% File Types
flist=dir([dr 'filetypes' filesep '*.xml']);
for ii=1:length(flist)    
    xml=xml2struct([dr 'filetypes' filesep flist(ii).name]);
    handles.filetype(ii).filetype=xml;
    handles.filetype(ii).filetype.name=flist(ii).name(1:end-4);
    handles.filetypes{ii}=flist(ii).name(1:end-4);
    % Fix element groups (if there's only one element group, it is read as a string...)
    if isfield(handles.filetype(ii).filetype,'elementgroup')
        if ischar(handles.filetype(ii).filetype.elementgroup)
           str=handles.filetype(ii).filetype.elementgroup;
           handles.filetype(ii).filetype.elementgroup=[];
           handles.filetype(ii).filetype.elementgroup.elementgroup=str;        
        end
    end
end

%% Plot Types
flist=dir([dr 'plottypes' filesep '*.xml']);
for ii=1:length(flist)
    handles.plottype(ii).plottype.subplotoption=[];
    handles.plottype(ii).plottype=xml2struct([dr 'plottypes' filesep flist(ii).name]);
    handles.plottype(ii).plottype.name=flist(ii).name(1:end-4);
end
% Annotation
handles.plottype(length(flist)+1).plottype.name='annotation';
handles.plottype(length(flist)+1).plottype.subplotoption=[];

%% Frames (also do str2num here, which is not consistent with other xml files, but that's okay)
dr=[handles.settingsdir 'frames' filesep];
flist=dir([dr '*.xml']);
n=0;
for ii=1:length(flist)
    xml=xml2struct([dr flist(ii).name]);
    for j=1:length(xml.frame)
        n=n+1;
        handles.frames.frame(n).frame=xml.frame(j).frame;
        handles.frames.names{n}=xml.frame(j).frame.name;
        handles.frames.longnames{n}=xml.frame(j).frame.longname;
        % Set some defaults
        if isfield(handles.frames.frame(n).frame,'box')
            for k=1:length(handles.frames.frame(n).frame.box)
                handles.frames.frame(n).frame.box(k).box.position=str2num(handles.frames.frame(n).frame.box(k).box.position);                
                if ~isfield(handles.frames.frame(n).frame.box(k).box,'linewidth')
                    handles.frames.frame(n).frame.box(k).box.linewidth=1;
                else
                    handles.frames.frame(n).frame.box(k).box.linewidth=str2double(handles.frames.frame(n).frame.box(k).box.linewidth);
                end
            end
        end
        if isfield(handles.frames.frame(n).frame,'text')
            for k=1:length(handles.frames.frame(n).frame.text)
                handles.frames.frame(n).frame.text(k).text.position=str2num(handles.frames.frame(n).frame.text(k).text.position);
                if isfield(handles.frames.frame(n).frame.text(k).text,'defaulttext')
                    handles.frames.frame(n).frame.text(k).text.defaulttext=handles.frames.frame(n).frame.text(k).text.defaulttext;
                end
                if ~isfield(handles.frames.frame(n).frame.text(k).text,'fontname')
                    handles.frames.frame(n).frame.text(k).text.fontname='Helvetica';
                end
                if ~isfield(handles.frames.frame(n).frame.text(k).text,'fontsize')
                    handles.frames.frame(n).frame.text(k).text.fontsize=8;
                else
                    handles.frames.frame(n).frame.text(k).text.fontsize=str2double(handles.frames.frame(n).frame.text(k).text.fontsize);
                end
                if ~isfield(handles.frames.frame(n).frame.text(k).text,'fontangle')
                    handles.frames.frame(n).frame.text(k).text.fontangle='normal';
                end
                if ~isfield(handles.frames.frame(n).frame.text(k).text,'fontweight')
                    handles.frames.frame(n).frame.text(k).text.fontweight='normal';
                end
                if ~isfield(handles.frames.frame(n).frame.text(k).text,'fontcolor')
                    handles.frames.frame(n).frame.text(k).text.fontcolor='Black';
                end
            end
        end
        if isfield(handles.frames.frame(n).frame,'logo')
            for k=1:length(handles.frames.frame(n).frame.logo)
                handles.frames.frame(n).frame.logo(k).logo.position=str2num(handles.frames.frame(n).frame.logo(k).logo.position);
            end
        end
    end
end

