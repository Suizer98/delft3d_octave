function path = EHY_path(path,win_or_unix)
% path = EHY_path(path,win_or_unix)
% Correct path for usage in either Unix or Windows
% path can be either a string or cell array of strings
%
% Example1: EHY_path('D:\folder\\script.m')
% returns on Windows:  'D:\folder\script.m'
% returns on Unix:     '/d/folder/script.m'
%
% Second input argument can be used to force output-style (Windows or Unix)
%
% Example2: EHY_path('D:\folder\\script.m','unix')
% returns (in unix):    '/d/folder/script.m'
%
% Example3: EHY_path('/d/folder/script.m','win')
% returns (in windows): 'D:\folder\script.m'
%
% created by Julien Groenenboom, September 2017
% Julien.Groenenboom@Deltares.nl

if isempty(path)
    return
end

if ~exist('win_or_unix','var')
    if ispc % Windows
        win_or_unix = 'w';
    elseif isunix % Unix
        win_or_unix = 'u';
    end
else
    win_or_unix = lower(win_or_unix(1));
end
    
if ischar(path)
    path = EHY_path_WinLin(path,win_or_unix);
elseif iscell(path)
    for iP = 1:length(path)
        path{iP} = EHY_path_WinLin(path{iP},win_or_unix);
    end
end

end

function path = EHY_path_WinLin(path,win_or_unix)

switch win_or_unix
    case 'w' % Windows
        
        % from /p/ to p:\
        if strcmp(path([1 3]),'//')
            path = [path(2) ':' path(3:end)];
        end
        % change '/' into '\'
        path = strrep(path,'/','\');
        
    case {'u','l'} % Unix (or Linux)
        
        % from p:\ to /p/
        if strcmp(path(2),':')
            path = ['/' lower(path(1)) path(3:end)];
        end
        % change '\' into '/'
        path = strrep(path,'\','/');
        
end

% remove double fileseps
deleteIndex = strfind(path,[filesep filesep]);
deleteIndex(deleteIndex == 1) = [];
path(deleteIndex) = '';
end
