function s=renamefield(s,fldname0,fldname1)
if isfield(s,fldname0)
    s.(fldname1)=s.(fldname0);
    s=rmfield(s,fldname0);
end
