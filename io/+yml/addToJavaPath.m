function addToJavaPath()
% Adds the Java yaml library to the dynamic path
%
% This should be performed at start of your application before using the
% yaml tools.
%
% Matlab help states:
%   Matlab> Advanced Software Development> Calling External Functions> 
%   Call Java Libraries> The Dynamic Path
%
%   The dynamic class path can be loaded any time during a MATLAB session
%   using the javaclasspath function. You can define the dynamic path,
%   modify the path, and refresh the Java class definitions for all classes
%   on the dynamic path without restarting MATLAB. 
% 
%   The functions javaaddpath and javaclasspath(dpath) add entries to the
%   dynamic class path. To avoid the possibility that the new path contains
%   a class or package with the same name as an existing class or package,
%   *** MATLAB CLEARS ALL EXISTING GLOBAL VARIABLES and VARIABLES IN THE
%   WORKSPACE. *** 
% 
%   Although the dynamic path offers more flexibility in changing the path,
%   Java classes on the dynamic path might load more slowly than classes on
%   the static path. 
%
% See also javaaddpath javaclasspath yml.removeFromJavaPath
if isdeployed
    jarFile = fullfile(getcurrentdir(),'snakeyaml-1.9.jar');
else
    jarFile = fullfile(fileparts(mfilename('fullpath')), 'external','snakeyaml-1.9.jar');
end
if not(ismember(jarFile, javaclasspath ('-dynamic')))
    javaaddpath(jarFile);
end