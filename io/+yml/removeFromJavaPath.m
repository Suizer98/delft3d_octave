function removeFromJavaPath()
% Removes yaml Java library from dynamic path and removes all java objects

% Tempory suppres warnings
w = warning ('off','all');

jarFile = fullfile(fileparts(mfilename('fullpath')), 'external','snakeyaml-1.9.jar');
if ismember(jarFile, javaclasspath ('-dynamic'))
    javarmpath(jarFile); % remove loaded path
end

% Restore warning state
warning(w);
