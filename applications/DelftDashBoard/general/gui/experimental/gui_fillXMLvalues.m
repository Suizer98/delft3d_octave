function xml=gui_fillXMLvalues(xml,varargin)
% Does some string to numeric conversions and adds default values

variableprefix=[];
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'variableprefix'}
                variableprefix=varargin{ii+1};
        end
    end
end

fldnames=fieldnames(xml);

screensize=get(0,'ScreenSize');
ihres=0;
if screensize(3)>1900
    ihres=1;
end

% First some conversions ...
for ii=1:length(fldnames)
    fldname=fldnames{ii};    
    switch fldname
        case{'enable','multipledomains','includenumbers','includebuttons','showfilename','fullpath','includenone','horizontalalignment','verticalalignment'}
            switch lower(xml.(fldname)(1))
                case{'y','1'}
                    xml.(fldname)=1;
                otherwise
                    xml.(fldname)=0;
            end
        case{'position'}
            pos=xml.position;
            if ischar(pos)
                pos=str2num(pos);
            end
            if length(pos)==3
                pos=[pos 20];
            elseif length(pos)==2
                pos=[pos 2000 20];
            end
            if ihres
                pos=pos*1.2;
            end
            xml.position=pos;
        case{'nrlines','nrrows','max','fontsize'}
            if ischar(xml.(fldname))
                xml.(fldname)=str2num(xml.(fldname));
            end
        case{'callback'}
            if ~isempty(xml.callback)
                xml.callback=str2func(xml.callback);
            end
        case{'onchange'}
            if ~isempty(xml.onchange)
                xml.callback=str2func(xml.onchange);
            end
        case{'fileextension'}
            xml.extension=xml.fileextension;
    end
end

% And now add missing values
for ii=1:length(fldnames)
    fldname=fldnames{ii};
    switch fldname
        case{'element'}
            for ielm=1:length(xml.element)
                xml.element(ielm).element=gui_fillXMLvalues(xml.element(ielm).element,'variableprefix',variableprefix);
                % Fill missing element values
                xml.element(ielm).element=fillMissingElementValues(xml.element(ielm).element,variableprefix);
                switch lower(xml.element(ielm).element.style)
                    case{'table'}
                        xml.element(ielm).element.column=fillMissingColumnValues(xml.element(ielm).element.column);
                end
            end
        case{'tab'}
            for itab=1:length(xml.tab)
                xml.tab(itab).tab=gui_fillXMLvalues(xml.tab(itab).tab,'variableprefix',variableprefix);
                xml.tab(itab).tab=fillMissingTabValues(xml.tab(itab).tab);
            end            
        case{'model'}
            if ~isfield(xml,'multipledomains')
                xml.multipledomains=0;
            end
            if ~isfield(xml,'enable')
                xml.enable=0;
            end
            if ~isfield(xml,'longname')
                xml.longname=xml.model;
            end
        case{'toolbox'}
            if ~isfield(xml,'enable')
                xml.enable=0;
            end
            if ~isfield(xml,'longname')
                xml.longname=xml.model;
            end
    end
end

%%
function el=fillMissingElementValues(el,variableprefix)

default.style=[];
default.position=[];
default.tag='';
default.name=[];
default.callback=[];
default.option1=[];
default.option2=[];
default.parent=[];
default.dependency=[];
default.multivariable=[];
default.includenumbers=0;
default.includebuttons=0;
default.nrrows=1;
default.nrlines=1;
default.enable=1;
default.horal='left';
default.prefix=[];
default.suffix=[];
default.title=[];
default.textposition='left';
default.tooltipstring=[];
default.extension=[];
default.selectiontext=[];
default.value=[];
default.showfilename=1;
default.fullpath=1;
default.type='string';
default.mx=[];
default.max=[];
default.bordertype='etchedin';
default.format='';
default.text='';
default.variableprefix=[];
default.listtext=[];
default.listvalue=[];

el.variableprefix=variableprefix;

fields=fieldnames(default);
for ii=1:length(fields)
    if ~isfield(el,fields{ii})
        el.(fields{ii})=default.(fields{ii});
    end
end

% Dependencies
for jj=1:length(el.dependency)
    if ~isfield(el.dependency(jj).dependency,'action')
        el.dependency(jj).dependency.action='enable';
    end
    if ~isfield(el.dependency(jj).dependency,'checkfor')
        el.dependency(jj).dependency.checkfor='all';
    end
    if ~isfield(el.dependency(jj).dependency,'check')
        el.dependency(jj).dependency.check=[];
    end
    for kk=1:length(el.dependency(jj).dependency.check)
        if ~isfield(el.dependency(jj).dependency.check(kk).check,'variable')
            el.dependencies(jj).dependency.check(kk).check.variable=[];
        end        
        if ~isfield(el.dependency(jj).dependency.check(kk).check,'operator')
            el.dependency(jj).dependency.checks(kk).check.operator=[];
        end
        if ~isfield(el.dependency(jj).dependency.check(kk).check,'value')
            el.dependency(jj).dependency.check(kk).check.value=[];
        end
    end
end

%%
function column=fillMissingColumnValues(column)

for jj=1:length(column)
    fields=fieldnames(column(jj).column);
    for kk=1:length(fields)
        fldname=fields{kk};
        switch lower(fldname)
            case{'width'}
                column(jj).column.(fldname)=str2num(column(jj).column.(fldname));
            case{'enable'}
                switch lower(column(jj).column.(fldname)(1))
                    case{'y','1'}
                        column(jj).column.(fldname)=1;
                    otherwise
                        column(jj).column.(fldname)=0;
                end
        end
    end
end

default.style=[];
default.width=50;
default.callback=[];
default.option1=[];
default.option2=[];
default.text=[];
default.popuptext=[];
default.enable=1;
default.format=[];
default.type=[];
default.stringlist=[];
default.variable=[];

fields=fieldnames(default);
for ii=1:length(fields)
    for jj=1:length(column)
        if ~isfield(column(jj).column,fields{ii})
            column(jj).column.(fields{ii})=default.(fields{ii});
        end
            
    end
end

%%
function tb=fillMissingTabValues(tb)

default.tab=[];
default.tabstring=[];
default.tabname=[];
default.callback=[];
default.element=[];
default.enable=1;
default.formodel=[];

fields=fieldnames(default);
for ii=1:length(fields)
    if ~isfield(tb,fields{ii})
        tb.(fields{ii})=default.(fields{ii});
    end
end

