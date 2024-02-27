function s = relativeToabsolutePath(s)
% this subfunction converts relative file paths to absolute file paths. The
% function is designed to make dir2 mimic the output of dir as much as
% possible
%
% TK: subtracted from dir2 to allow for use directly

s = fullfile(s,'');

if isempty(s)
    s = pwd;
elseif s(1) == filesep
    % then basepath is relative unless second entry of s is also a filesep
    % indicating a network path
    if length(s)>1
        if s(2) == filesep
            % it is already an absolute networkpath
        else
            tmp = pwd;
            % Only on windows assume that the first two letters of tmp are
            % the drive letter
            if ispc
                s  = [tmp(1:2) s];
            end
        end
    else
        tmp = pwd;

        if ispc
        s   = [tmp(1:2) s];
        end
    end
elseif strcmp(s,'.')
    s   = pwd;
elseif strcmp(s,'..')
    s   = [pwd filesep s];
else
    if length(s) >= 2
        if strcmp(s(2),':')
            % it is already an absolute path
        else
            s   = [pwd filesep s];
        end
    else
        s   = [pwd filesep s];
    end
end

% append filesep (TK: only if s does not contail a '.' in which case it is
% a file)
if ~strcmp(s(end),filesep) && isempty(strfind(s,'.'))
    s = [s filesep];
end

% remove 'up one folder' statements ('../')
while 1
    a = strfind(s,filesep);
    b = strfind(s,[filesep '..' filesep]);

    if isempty(b)
        return
    end
    c = find(ismember(a,b));
    if c(1)==1;
        s = s([1:a(c(1)) a(c(1)+1)+1 : end]);
    else
        s = s([1:a(c(1)-1) a(c(1)+1)+1 : end]);
    end
end
