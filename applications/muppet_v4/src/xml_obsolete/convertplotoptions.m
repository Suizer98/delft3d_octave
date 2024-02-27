clear variables;close all;
dr='d:\checkouts\OpenEarthTools\trunk\matlab\applications\muppet_v4\src\xml\plotoptions\';
flist=dir([dr '*.xml']);

mkdir('plotoptions');
mkdir('elementgroups');
mkdir('elementgroups\plotoptions');

% Plot options
nopt=0;
plotoption=[];
for ii=1:length(flist)
    %     if strcmpi(flist(ii).name,'misc.xml')
    %         % Also include misc
    %         s=xml2struct([dr flist(ii).name]);
    %
    %     else
    s=xml2struct([dr flist(ii).name]);
    for ipl=1:length(s.plotoption)
        % First make individual plot options
        if ~isfield(s.plotoption(ipl).plotoption,'element')
            nopt=nopt+1;
            plotoption(nopt).plotoption.name=s.plotoption(ipl).plotoption.name;
            plotoption(nopt).plotoption.variable=s.plotoption(ipl).plotoption.name;
            plotoption(nopt).plotoption.keyword=s.plotoption(ipl).plotoption.keyword;
            try
            plotoption(nopt).plotoption.type=s.plotoption(ipl).plotoption.type;
            catch
                shite=1
            end
            if isfield(s.plotoption(ipl).plotoption,'write')
                plotoption(nopt).plotoption.write=s.plotoption(ipl).plotoption.write;
            end
        else
            for iel=1:length(s.plotoption(ipl).plotoption.element)
                if strcmpi(flist(ii).name,'misc.xml')
                    s.plotoption(ipl).plotoption.element(iel).element.variable=s.plotoption(ipl).plotoption.name;
                    s.plotoption(ipl).plotoption.element(iel).element.keyword=s.plotoption(ipl).plotoption.keyword;                    
                end
                if isfield(s.plotoption(ipl).plotoption.element(iel).element,'variable') && isfield(s.plotoption(ipl).plotoption.element(iel).element,'keyword')
                    el=s.plotoption(ipl).plotoption.element(iel).element;
                    opt=[];
                    % Name
                    if isfield(el,'name')
                        name=lower(el.name);
                    else
                        name=lower(el.variable);
                    end
                    name(name=='.')='';
                    
                    plotoptionnames={'abcdefg'};
                    for j=1:length(plotoption)
                        if ischar(plotoption(j).plotoption.name)
                            plotoptionnames{j}=plotoption(j).plotoption.name;
                        else
                            plotoptionnames{j}=plotoption(j).plotoption.name.name;
                        end
                    end
                    j=strmatch(name,plotoptionnames,'exact');
                    if ~isempty(j)
                        break
                    end
                    
                    opt.name.name=name;
                    opt.variable.variable=el.variable;
                    if isfield(el,'type')
                        opt.type.type=el.type;
                    end
                    if isfield(el,'keyword')
                        opt.keyword.keyword=el.keyword;
                    end
                    if isfield(el,'keyword2')
                        opt.keyword2.keyword2=el.keyword2;
                    end
                    if isfield(el,'default')
                        if isstruct(el.default)
                            for j=1:length(el.default)
                                opt.default(j).default=el.default(j).default;
                            end
                        else
                            opt.default.default=el.default;
                        end
                    else
                        disp(['No default for ' name]);
                    end
                    if isfield(el,'check')
                        if isfield(el,'checkfor')
                            checkfor=el.checkfor;
                        else
                            checkfor='all';
                        end
                        opt.dependency.dependency.action.action='write';
                        opt.dependency.dependency.checkfor.checkfor=checkfor;
                        n=length(el.check);
                        for j=1:n
                            if isfield(el.check(j).check,'variable')
                                var=el.check(j).check.variable;
                            else
                                var=opt.variable.variable;
                            end
                            opt.dependency.dependency.check(j).check.variable.variable=var;
                            switch el.check(j).check.operator
                                case{'notempty'}
                                    val='isempty';
                                    operator='ne';
                                otherwise
                                    operator=el.check(j).check.operator;
                                    if isfield(el.check(j).check,'value')
                                        val=el.check(j).check.value;
                                    else
                                        val=opt.default.default;
                                    end
                            end
                            opt.dependency.dependency.check(j).check.operator.operator=operator;
                            opt.dependency.dependency.check(j).check.value.value=val;
                        end
                        
                    end
                    
                    nopt=nopt+1;
                    plotoption(nopt).plotoption=opt;
                    
                end
            end
        end
    end
end

s.plotoption=plotoption;

struct2xml('plotoptions/plotoptions.xml',s,'structuretype','short');

% % Plot option groups
% for ii=1:length(flist)
%     if strcmpi(flist(ii).name,'misc.xml')
%     else
%         s=xml2struct([dr flist(ii).name]);
%         % First make individual plot options
%         ngr=0;
%         plotoptiongroup=[];
%         for iel=1:length(s.plotoption.plotoption.element)
%             if isfield(s.plotoption.plotoption.element(iel).element,'variable')
%                 el=s.plotoption.plotoption.element(iel).element;
%                 opt=[];
%                 % Name
%                 if isfield(el,'name')
%                     name=lower(el.name);
%                 else
%                     name=lower(el.variable);
%                 end
%                 name(name=='.')='';
%                 if isfield(el,'keyword')
%                     ngr=ngr+1;
%                     plotoptiongroup.plotoption(ngr).plotoption=name;
%                 end
%             end
%         end
%         fname=flist(ii).name;
%         ist=strfind(fname,'group');
%         if ~isempty(ist)
%             fname=[fname(1:ist-1) fname(ist+5:end)];
%         end
%         struct2xml(['plotoptiongroups/' fname],plotoptiongroup,'structuretype','short');
%     end
% end

% Plot option groups
for ii=1:length(flist)
    %     if strcmpi(flist(ii).name,'misc.xml')
    %     else
    s=xml2struct([dr flist(ii).name]);
    % First make individual plot options
    for ipl=1:length(s.plotoption)
        if isfield(s.plotoption(ipl).plotoption,'element')
            
            ngr=0;
            elementgroup=[];
            
            for iel=1:length(s.plotoption(ipl).plotoption.element)
                el=s.plotoption(ipl).plotoption.element(iel).element;
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
            struct2xml(['elementgroups/plotoptions/' fname],elementgroup,'structuretype','short');
        end
    end
end
