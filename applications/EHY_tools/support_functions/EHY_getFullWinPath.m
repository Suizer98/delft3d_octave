function fullWinPath=EHY_getFullWinPath(name_and_ext,pathstr)
%% fullWinPath=EHY_getFullWinPath(name_and_ext,pathstr)
%
% This function returns the full/aboslute windows path based
% on the name+extension of a file and a path.
%
% Example1: 	fullWinPath=EHY_getFullWinPath('model.mdu','/p/123-name/runs/')
%               fullWinPath='p:\123-name\runs\model.mdu'
% Example2: 	fullWinPath=EHY_getFullWinPath('/p/123-name/runs/model.mdu')
%               fullWinPath='p:\123-name\runs\model.mdu'
% Example3: 	fullWinPath=EHY_getFullWinPath('/p/123-name/runs/model.mdu','/p/123-name/runs/')
%               fullWinPath='p:\123-name\runs\model.mdu'
%
% support function of the EHY_tools
% Julien Groenenboom - E: Julien.Groenenboom@deltares.nl

% string2cell
if ~iscell(name_and_ext)
    name_and_ext=cellstr(name_and_ext);
end

for iN=1:length(name_and_ext)
    name=name_and_ext{iN};
    % from /p/ to p:/
    if strcmp(name([1 3]),'//')
        name=[name(2) ':' name(3:end)];
    end
    if exist('pathstr','var') && strcmp(pathstr([1 3]),'//')
        pathstr=[pathstr(2) ':' pathstr(3:end)];
    end
    
    % pathstr+name > fullWinPath
    if isempty(strfind(name,':')) % if paths are given as in Example1
        fullWinPathThisFile=[pathstr filesep name];
    else % if paths are given as in Example2 or Example3
        fullWinPathThisFile=name;
    end
    
    fullWinPathThisFile=strrep(fullWinPathThisFile,'/','\');
    fullWinPathThisFile=strrep(fullWinPathThisFile,'\\','\');
    
    fullWinPath{iN}=fullWinPathThisFile;
end

if length(fullWinPath)==1
    fullWinPath=fullWinPath{1}; % set back to string
end
