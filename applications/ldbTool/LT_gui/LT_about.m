function LT_about(varargin)
%LT_ABOUT ldbTool GUI function that displays the about-information
%
%   See also ldbTool

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

if nargin == 0
    test = 'no';
else
    test = varargin{1};
end

aboutPath = ShowPath;

fid=fopen([aboutPath filesep 'LT_about.txt']);
aboutText=fread(fid,'char');
aboutText(aboutText==13)=[];
aboutText = char(aboutText');

if ~isdeployed
    revnumb = '????';
    [tf str] = system(['svn info ' fileparts(which('ldbTool.m'))]);
    str = strread(str,'%s','delimiter',char(10));
    id = strncmp(str,'Revision:',8);
    if any(id)
        revnumb = strcat(str{id}(min(strfind(str{id},':'))+1:end));
    end
    aboutText = regexprep(aboutText,{'\$revision','\$year','\$month'},{revnumb,datestr(now,'mmmm'),datestr(now,'yyyy')});
end

h = msgbox(aboutText,'About ldbTool','modal');
switch test
    case 'no'
        uiwait(h);
    case 'yes'
        drawnow;
        close(h);
        drawnow; % Update matlab before it rushes into problems
end
    

function [thePath] = ShowPath()
% Show EXE path:
if isdeployed % Stand-alone mode.
    [status, result] = system('set PATH');
    thePath = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
else % Running from MATLAB.
    [macroFolder, baseFileName, ext] = fileparts(mfilename('fullpath'));
    thePath = macroFolder;
    % thePath = pwd;
end