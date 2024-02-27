function [value] = getvalue(fid,keyword)
s=fgetl(fid);
col=find(s=='=');
if ~isempty(col)
    key=strtrim(s(1:col-1));
    if strcmp(key,keyword)
        value=strtrim(s(col+1:end));
    else
        value=[];
    end
end

