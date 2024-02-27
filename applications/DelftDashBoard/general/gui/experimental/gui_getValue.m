function val=gui_getValue(el,v)
% Gets value from global structure

val=[];

if isfield(el,'handle')
    
    % Using GUI and getFcn approach
    
    getFcn=getappdata(el.handle,'getFcn');
    
    if length(v)>=11
        if strcmpi(v(1:11),'mainhandles')
            getFcn=@getHandles;
        end
    end
    
    s=feval(getFcn);
    
    % Variable name
    if ~isfield(el,'variableprefix')
        el.variableprefix=[];
    end
    
    if ~isempty(el.variableprefix)
        varstring=['s.' el.variableprefix '.' v];
    else
        varstring=['s.' v];
    end
    
    % assignin(ws, 'var', val);
    
    % Dashboard adaptation
    % If variable name starts with 'handles'
    if length(v)>=7
        if strcmpi(v(1:7),'handles')
            varstring=v;
            varstring=strrep(varstring,'handles','s');
        end
    end
    if length(v)>=11
        if strcmpi(v(1:11),'mainhandles')
            varstring=v;
            varstring=strrep(varstring,'mainhandles','s');
        end
    end
    
else
    % el contains all the data (used in Muppet writing of session files)
    varstring=['el.' v];
end

try
    val=eval(varstring);
catch
    switch el.type
        case{'string'}
            val='';
        case{'int','integer'}
            val=NaN;
        case{'real'}
            val=NaN;
        otherwise
            disp(['Could not determine value of ' varstring]);
    end
end
