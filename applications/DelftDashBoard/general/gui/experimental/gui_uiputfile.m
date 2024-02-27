function [filename,ok]=gui_uiputfile(filter,ttl,file)
ok=1;
[filename, pathname, filterindex] = uiputfile(filter,ttl,file);
if pathname==0
    ok=0;
    return
end
if ~strcmpi(pathname(1:end-1),pwd)
    filename=[pathname filename];
end
