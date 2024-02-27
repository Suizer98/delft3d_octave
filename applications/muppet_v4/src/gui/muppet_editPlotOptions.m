function handles=muppet_editPlotOptions(handles)

plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
dataset=plt.datasets(handles.activedatasetinsubplot).dataset;

axestype=plt.type;
datatype=dataset.type;

%% Find datatype
idtype=strmatch(datatype,handles.datatypenames,'exact');
if isempty(idtype)
    disp(['Data type ' datatype ' not found!']);
    return
end

%% Find plot options for data type
ip=muppet_findIndex(handles.datatype(idtype).datatype.plottype,'plottype','name',axestype);
datatype=handles.datatype(idtype).datatype.plottype(ip).plottype;

nplotroutines=length(datatype.plotroutine);

% First determine width and height of element groups
for ipr=1:nplotroutines
    if isfield(datatype.plotroutine(ipr).plotroutine,'elementgroup')
        elementgroup=datatype.plotroutine(ipr).plotroutine.elementgroup;
        for ii=1:length(elementgroup)
            name=elementgroup(ii).elementgroup;
            iopt=strmatch(name,handles.plotoptionelementgroupnames,'exact');
            widthopt(ipr,ii)=handles.plotoptionelementgroup(iopt).plotoptionelementgroup.width;
            heightopt(ipr,ii)=handles.plotoptionelementgroup(iopt).plotoptionelementgroup.height;
        end
    end
end

% Now determine total height and width of figure
width=0;
height=0;
for ipr=1:nplotroutines
    if isfield(datatype.plotroutine(ipr).plotroutine,'elementgroup')
        elementgroup=datatype.plotroutine(ipr).plotroutine.elementgroup;
        wdt=0;
        hgt=0;
        for ii=1:length(elementgroup)
            wdt=max(wdt,widthopt(ipr,ii));
            hgt=hgt+heightopt(ipr,ii)+10;
        end
        width=max(width,wdt);
        height=max(height,hgt);
    end
end

if nplotroutines>1
    % Add some extra space for plot routine popup menu
    height=height+20;
end
% Add extra space for ok and cancel buttons
height=height+100;
% Set minimum width
width=max(400,width);

% Popupmenu for plot routines
nelm=0;
if nplotroutines>1
    nelm=nelm+1;
    element(nelm).element.style='popupmenu';
    element(nelm).element.text='Plot Routine';
    element(nelm).element.textposition='above-left';
    element(nelm).element.variable='plotroutine';
    element(nelm).element.type='string';
    element(nelm).element.position=[25 height-50 200 20];
    for ipr=1:nplotroutines
        if isfield(datatype.plotroutine(ipr).plotroutine,'longname')
            name=datatype.plotroutine(ipr).plotroutine.longname;
        else
            name=datatype.plotroutine(ipr).plotroutine.name;
        end
        element(nelm).element.listtext(ipr).listtext=name;
        element(nelm).element.listvalue(ipr).listvalue=datatype.plotroutine(ipr).plotroutine.name;
    end
end

% And now add all the other elements
for ipr=1:nplotroutines
    
    if nplotroutines>1
        % Multiple plot routines, put element groups in different panels
        nelm=nelm+1;
        element(nelm).element.style='panel';
        element(nelm).element.tag=['panel' num2str(ipr)];
        element(nelm).element.bordertype='none';
        element(nelm).element.dependency.dependency.action='visible';
        element(nelm).element.dependency.dependency.checkfor='all';
        element(nelm).element.dependency.dependency.check.check.variable='plotroutine';
        element(nelm).element.dependency.dependency.check.check.value=datatype.plotroutine(ipr).plotroutine.name;
        element(nelm).element.dependency.dependency.check.check.operator='eq';
        element(nelm).element.position=[0 0 width height-50];
        posy=height-60;
    else
        posy=height-10;
    end
    
    if isfield(datatype.plotroutine(ipr).plotroutine,'elementgroup')
        for ii=1:length(datatype.plotroutine(ipr).plotroutine.elementgroup)
            
            name=datatype.plotroutine(ipr).plotroutine.elementgroup(ii).elementgroup;
            
            % Find element in plot options element file
            iopt=strmatch(name,handles.plotoptionelementgroupnames,'exact');
            
            elementgroup=handles.plotoptionelementgroup(iopt).plotoptionelementgroup;
            
            posy=posy-heightopt(ipr,ii)-10;
            
            posori(1)=25;
            posori(2)=posy;
            
            for ielm=1:length(elementgroup.element)
                el=elementgroup.element(ielm).element;
                if isfield(el,'style')
                    nelm=nelm+1;
                    % Position relative to lower left corner
                    pos=str2num(el.position);
                    position=[posori(1)+pos(1) posori(2)+pos(2) pos(3) pos(4)];
                    if isfield(elementgroup,'positionx')
                        position(1)=position(1)+str2double(elementgroup.positionx);
                    end
                    el.position=position;
                    if nplotroutines>1
                        el.parent=['panel' num2str(ipr)];
                    end
                    element(nelm).element=el;
                end
            end
        end
    end
end

nelm=nelm+1;
element(nelm).element.style='pushcancel';
element(nelm).element.position=[width-175 25 70 25];
element(nelm).element.tag='cancel';

nelm=nelm+1;
element(nelm).element.style='pushok';
element(nelm).element.position=[width-95 25 70 25];
element(nelm).element.tag='ok';

xml.element=element;

xml=gui_fillXMLvalues(xml);

[dataset,ok]=gui_newWindow(dataset,'element',xml.element,'tag','uifigure','width',width,'height',height, ...
    'title',[handles.datatype(idtype).datatype.longname],'iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);

if ok
    plt.datasets(handles.activedatasetinsubplot).dataset=dataset;
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;
end
