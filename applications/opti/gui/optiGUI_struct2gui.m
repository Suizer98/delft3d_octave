function optiGUI_struct2gui(fig);

this=get(fig,'userdata');

dg=str2num(get(findobj(fig,'tag','curDg'),'string'));

nodg=length(this.input);
set(findobj(fig,'tag','maxDg'),'string',num2str(nodg));

if ~isempty(this.input(dg).inputType)
    set(findobj(fig,'tag','inputType'),'value',this.input(dg).inputType);
else
    set(findobj(fig,'tag','inputType'),'value',1);
end

if ~isempty(this.input(dg).trimTimeStep)
    set(findobj(fig,'tag','trimTimeStep'),'string',num2str(this.input(dg).trimTimeStep));
else
    set(findobj(fig,'tag','trimTimeStep'),'string',' ');    
end

if ~isempty(this.input(dg).dataType)
    set(findobj(fig,'tag','dataType'),'value',find(strcmp(this.input(dg).dataType,get(findobj(fig,'tag','dataType'),'string'))));
    switch this.input(dg).dataType
        case 'transport'
            set(findobj(fig,'tag','transportType'),'enable','on');
            set(findobj(fig,'tag','dataSedimentFraction'),'enable','on');
        case 'sedero'
            set(findobj(fig,'tag','transportType'),'enable','off');
            set(findobj(fig,'tag','dataSedimentFraction'),'enable','off');
    end
else
    set(findobj(fig,'tag','dataType'),'value',1);    
end

if ~isempty(this.input(dg).transParameter)
    set(findobj(fig,'tag','transportType'),'value',find(strcmp(this.input(dg).transParameter,get(findobj(fig,'tag','transportType'),'string'))));
else
    set(findobj(fig,'tag','transportType'),'value',1);    
end

% new feature, first check for existence of keyword (backward compatible)
if isfield(this.input(dg),'transportMode')
    if ~isempty(this.input(dg).transportMode)
        switch this.input(dg).transportMode
            case 'nett'
                set(findobj(fig,'tag','grossMode'),'Value',0);
            case 'gross'
                set(findobj(fig,'tag','grossMode'),'Value',1);
        end
    else
        set(findobj(fig,'tag','grossMode'),'value',0);
    end
else
    set(findobj(fig,'tag','grossMode'),'value',0);
end

if ~isempty(this.input(dg).dataSedimentFraction)
    set(findobj(fig,'tag','dataSedimentFraction'),'value',this.input(dg).dataSedimentFraction);
else
    set(findobj(fig,'tag','dataSedimentFraction'),'value',1);    
end

if ~isempty(this.input(dg).dataTransect)
    set(findobj(fig,'tag','dataTransect'),'value',1);
    set(findobj(fig,'tag','dataTransect'),'string',['Use transect - Transects info: ' num2str(size(this.input(dg).dataTransect,3)) ' transects loaded']);
else
    set(findobj(fig,'tag','dataTransect'),'value',0);
    set(findobj(fig,'tag','dataTransect'),'string',['Use transect - No transect loaded']);
end

if ~isempty(this.input(dg).dataPolygon)
    set(findobj(fig,'tag','dataPolygon'),'value',1);
    set(findobj(fig,'tag','dataPolygon'),'string',['Use polygon - Polygon info: polygon consists of ' num2str(size(this.input(dg).dataPolygon,1)) ' points']);
else
    set(findobj(fig,'tag','dataPolygon'),'value',0);
    set(findobj(fig,'tag','dataPolygon'),'string',['Use polygon - No polygon loaded']);
end

if ~isempty(this.input(dg).data)
    set(findobj(fig,'tag','dataLoad'),'string',['Data already loaded, data info: ' char(13) 'Number of datapoints: ' num2str(size(this.input(dg).data,1)) char(13) 'Number of conditions: ' num2str(size(this.input(dg).data,2))]);
    set(findobj(fig,'tag','optiRunner'),'enable','on');
else
    set(findobj(fig,'tag','dataLoad'),'string','Data not loaded yet');
    set(findobj(fig,'tag','optiRunner'),'enable','off');    
end

if ~isfield(this.iteration,'iteration')
    set(findobj(fig,'tag','optiPostProc'),'enable','off');
else
    set(findobj(fig,'tag','optiPostProc'),'enable','on');
end

if ~isempty(this.input(dg).target)&~isfield(this.iteration,'iteration')
    set(findobj(fig,'tag','allCond'),'value',0);
    set(findobj(fig,'tag','userDefined'),'value',1);
else
    set(findobj(fig,'tag','userDefined'),'value',0);
    set(findobj(fig,'tag','allCond'),'value',1);
end

if ~isempty(this.weights)
    set(findobj(fig,'tag','weightBox'),'String',[repmat('condition ',length(this.weights),1) num2str([1:length(this.weights)]','%4.0f') repmat(': ',length(this.weights),1) num2str(this.weights','%3.3f')]);
else
    set(findobj(fig,'tag','weightBox'),'String','Weights');
end

if ~isempty(this.dataGroupWeights)
    set(findobj(fig,'tag','dataGroupWeight'),'string',num2str(this.dataGroupWeights(dg)));
else
    set(findobj(fig,'tag','dataGroupWeight'),'string',num2str(0));
end

optiGUI_setTrimInfo(fig);
optiGUI_setTimeFormat(fig);