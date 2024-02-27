clear variables;close all;
dr='d:\checkouts\OpenEarthTools\trunk\matlab\applications\muppet_v4\src\xml\dataproperties\';
flist=dir([dr '*.xml']);

mkdir('dataproperties');
mkdir('elementgroups');
mkdir('elementgroups\dataproperties');

% Plot options
nopt=0;
dataproperty=[];
for ii=1:length(flist)
    s0=xml2struct([dr flist(ii).name]);
    if isfield(s0.dataproperty.dataproperty,'name')
        s.dataproperty(ii).dataproperty.name=s0.dataproperty.dataproperty.name;
    end
    if isfield(s0.dataproperty.dataproperty,'keyword')
        s.dataproperty(ii).dataproperty.keyword=s0.dataproperty.dataproperty.keyword;
    end
    if isfield(s0.dataproperty.dataproperty,'variable')
        s.dataproperty(ii).dataproperty.variable=s0.dataproperty.dataproperty.variable;
    else
        s.dataproperty(ii).dataproperty.variable=s0.dataproperty.dataproperty.name;
    end
    if isfield(s0.dataproperty.dataproperty,'type')
        s.dataproperty(ii).dataproperty.type=s0.dataproperty.dataproperty.type;
    end
end

struct2xml('dataproperties/dataproperties.xml',s,'structuretype','short');

% Plot option groups
for ii=1:length(flist)
    s=xml2struct([dr flist(ii).name]);
    % First make individual plot options
    ngr=0;
    elementgroup=[];
    if isfield(s.dataproperty.dataproperty,'element')
        for iel=1:length(s.dataproperty.dataproperty.element)
            el=s.dataproperty.dataproperty.element(iel).element;
            if isfield(el,'style')
                ngr=ngr+1;
                if isfield(el,'variable')
                    elementgroup.element(ngr).element.variable.variable=el.variable;
                end
                if isfield(el,'type')
                    elementgroup.element(ngr).element.type.type=el.type;
                end
                elementgroup.element(ngr).element.style.style=el.style;
                elementgroup.element(ngr).element.position.position=el.position;
                if isfield(el,'listtext')
                    elementgroup.element(ngr).element.listtext=el.listtext;
                end
                if isfield(el,'listvalue')
                    elementgroup.element(ngr).element.listvalue=el.listvalue;
                end
                if isfield(el,'includenone')
                    elementgroup.element(ngr).element.includenone=el.includenone;
                end
                if isfield(el,'includeauto')
                    elementgroup.element(ngr).element.includeauto=el.includeauto;
                end
                if isfield(el,'value')
                    elementgroup.element(ngr).element.value=el.value;
                end
                if isfield(el,'callback')
                    elementgroup.element(ngr).element.callback.callback=el.callback;
                end
                if isfield(el,'option1')
                    elementgroup.element(ngr).element.option1.option1=el.option1;
                end
                if isfield(el,'option2')
                    elementgroup.element(ngr).element.option2.option2=el.option2;
                end
                if isfield(el,'text')
                    elementgroup.element(ngr).element.text.text=el.text;
                end
                if isfield(el,'textposition')
                    elementgroup.element(ngr).element.textposition.textposition=el.textposition;
                end
                if isfield(el,'tooltipstring')
                    elementgroup.element(ngr).element.tooltipstring.tooltipstring=el.tooltipstring;
                end
                if isfield(el,'dependency')
                    elementgroup.element(ngr).element.dependency=el.dependency;
                end
            end
        end
        fname=flist(ii).name;
        ist=strfind(fname,'group');
        if ~isempty(ist)
            fname=[fname(1:ist-1) fname(ist+5:end)];
        end
        struct2xml(['elementgroups/dataproperties/' fname],elementgroup,'structuretype','short');
    end
end
