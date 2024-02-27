function [xInitial zInitial D50 WL_t Hsig_t Tp_t] = parseDUROSinput(OPT, varargin)
%PARSEDUROSINPUT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = parseDUROSinput(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   parseDUROSinput
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 04 Mar 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: parseDUROSinput.m 4230 2011-03-10 11:00:23Z geer $
% $Date: 2011-03-10 19:00:23 +0800 (Thu, 10 Mar 2011) $
% $Author: geer $
% $Revision: 4230 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/analysis/parseDUROSinput.m $
% $Keywords: $

%% Begin function 
idPropName = cellfun(@ischar, varargin);
id = length(varargin);
if any(idPropName)
    id = find(idPropName, 1, 'first')-1;
end
varNames = fieldnames(OPT)';
% create propertyName propertyValue cell array (varargin like) with empty
% values for the first input arguments where propertyNames are omitted
OPTstructArgs = reshape([varNames(1:id); repmat({[]}, 1, id)], 1, 2*id);
% add the actual input arguments in the cell array
OPTstructArgs(2:2:2*id) = varargin(1:id);
% split input and settings
idnr = find(idPropName);
idstr = idnr(~ismember(varargin(idPropName),varNames));
if any(diff(idstr)==1)
   % one of the properties is a setting in string format
   idstr([false diff(idstr)==1]) = [];
end
settings = {};
for isettings = 1:length(idstr)
    settings = cat(2,settings,varargin{idstr(isettings):idstr(isettings)+1});
end
varargin(cat(2,idstr,idstr+1))=[];
% apply settings
DuneErosionSettings('set',settings{:});
% extend the cell array with the propertyName propertyValue pairs part of
% the input that are not settings
OPTstructArgs = [OPTstructArgs varargin(id+1:end)];
% include the input in the OPT-structure
[OPT, Set, Default] = setproperty(OPT, OPTstructArgs{:});
% find which variables are still default and not set.
defaultsid = cell2mat(struct2cell(Default)') & ~cell2mat(struct2cell(Set)');
for varName = varNames(defaultsid)
    % use getdefaults to generate the relevant messages
    getdefaults(varName{1}, OPT.(varName{1}), 1);
end
% put OPT-structure contents into separate variables
[xInitial zInitial D50 WL_t Hsig_t Tp_t] = deal(OPT.xInitial, OPT.zInitial, OPT.D50, OPT.WL_t, OPT.Hsig_t, OPT.Tp_t);
end