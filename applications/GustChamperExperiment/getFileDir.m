function varargout = getFileDir(varargin)
%UNTITLED  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = Untitled(varargin)
%
%   Input: For <keyword,value> pairs call Untitled() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   Untitled
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 <COMPANY>
%       kpru
%
%       <EMAIL>	
%
%       <ADDRESS>
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 11 Sep 2014
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
OPT = setOptions();

% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code

b = genpath(OPT.dir);
s = strread(b, '%s','delimiter', pathsep);  % read path as cell
filepaths={};
wb = waitbar(0,'Find files...');
for i = 1:size(s,1)
    waitbar(i/size(s,1))
    tmp = dir([s{i},filesep,OPT.contains]);
    if ~isempty(tmp)
        for j = 1:size(tmp,1)
            %check for subfolder
            foldername = {tmp(j).name};
            folder = tmp(j).isdir;
            while folder>0
                folder = 0;
                files   = dir([s{i},filesep,foldername{end}]);
                files   = {files([files.isdir]).name};
                for k = 1:size(files,2)
                    if ~strcmp(files{k}(1),'.')
                        foldername{end+1} = files{k};
                        if ~isempty(dir([s{i},filesep,tmp(j).name,filesep,foldername{end},filesep, '*',OPT.fext]))
                            filepaths{end+1} = [s{i},filesep,tmp(j).name,filesep,foldername{end}];
                        end
                        folder = 1;
                    end
                end
            end
            if ~isempty(dir([s{i},filesep,tmp(j).name,filesep,'*',OPT.fext]))
                filepaths{end+1} = [s{i},filesep,tmp(j).name];
            end
        end
    end
end

close(wb)
varargout = {filepaths(:)};
