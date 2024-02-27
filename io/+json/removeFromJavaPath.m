function removeFromJavaPath()
% Removes json Java library from dynamic path and removes all java objects

% Tempory suppres warnings
w = warning ('off','all');

jarFile = fullfile(fileparts(mfilename('fullpath')), 'java', 'json.jar');
if ismember(jarFile, javaclasspath ('-dynamic'))
    javarmpath(jarFile); % remove loaded path
end

% Restore warning state
warning(w);