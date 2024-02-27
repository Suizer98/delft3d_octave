function gui_setValue(el,v,val)
% Sets value in global structure

getFcn=getappdata(el.handle,'getFcn');
setFcn=getappdata(el.handle,'setFcn');

s=feval(getFcn);

% Variable name
if ~isempty(el.variableprefix)
    varstring=['s.' el.variableprefix '.' v];
else
    varstring=['s.' v];
end

% Dashboard adaptation
% If variable name starts with 'handles' 
if length(v)>=7
    if strcmpi(v(1:7),'handles')
        varstring=v;
        varstring=strrep(varstring,'handles','s');
    end
end

eval([varstring '=val;']);

feval(setFcn,s);
