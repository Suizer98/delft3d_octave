function name = nesthd_strippath(fullname)

% gives back just the filename from the entire, fullpath, name

name = '';
if ~isempty(fullname)
    [~,fname,fext] = fileparts(fullname);
    name = [fname fext];
end

