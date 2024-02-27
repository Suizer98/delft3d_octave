function variables = xb_get_varinfo(fpath)
%XB_GET_VARINFO  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_get_varinfo(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_get_varinfo
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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
% Created: 17 Nov 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_get_varinfo.m 5509 2011-11-18 16:25:46Z geer $
% $Date: 2011-11-19 00:25:46 +0800 (Sat, 19 Nov 2011) $
% $Author: geer $
% $Revision: 5509 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_get_varinfo.m $
% $Keywords: $

%% read params.f90
if ~exist('fpath','var')
    fpath = abspath(fullfile(fileparts(mfilename('fullpath')), '..', '..', '..', '..', 'fortran', 'XBeach'));
else
    if ~exist(fpath, 'dir') || isempty(fpath)
        fpath = abspath(fullfile(fileparts(mfilename('fullpath')), '..', '..', '..', '..', 'fortran', 'XBeach'));
    end
end

paramfile='spaceparams.tmpl';
paramsfname=fullfile(fpath, paramfile);
matfile = fullfile(fileparts(mfilename('fullpath')), 'variables.mat');
variables = [];

if exist(paramsfname, 'file')
    fid = fopen(paramsfname,'r');
    str = fread(fid,'*char');
    fclose(fid);
    cll = strread(str,'%s','delimiter',char(10));
    variables = struct(...
        'Name',[],...
        'StandardName',[],...
        'Type',[],...
        'NDims',[],...
        'Dimensions',[],...
        'BroadCasted',[],...
        'Unit',[],...
        'Description',[]);
    for i = 1:length(cll)
        if strncmp(cll{i},'!*',2)
            continue;
        end
        tempString = strread(cll{i},'%s','delimiter',' ');
        unitsId = find(~cellfun(@isempty,regexp(tempString,'\[*.\]')),1,'first');
        longNameId = find(~cellfun(@isempty,regexp(tempString,'\[*.\]')),1,'last');
        
        variables(i).Name = tempString{3};
        variables(i).Type = tempString{1};
        variables(i).NDims = str2double(tempString{2});
        variables(i).NDims = tempString(4:unitsId-1);
        variables(i).BroadCasted = tempString{unitsId - 1};
        variables(i).Unit = tempString{unitsId};
        standardName = tempString{longNameId}(2:end-1);
        if isempty(standardName)
            standardName = '';
        end
        variables(i).StandardName = standardName;
        len = length(tempString) - longNameId;
        str = reshape([tempString(longNameId+1:end)'; repmat({' '},1,len)],...
            1,len*2);
        variables(i).Description = cat(2,str{:});
    end
    variables(cellfun(@isempty,{variables.Name})) =[];
        
    if ~exist(matfile, 'file'); save(matfile, '-mat', 'variables'); end;
else
    if exist(matfile,'file');
        load(matfile);
    end
end
