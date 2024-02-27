function x0except = valleypoints(xInitial,zInitial,WL,varargin)
%VALLEYPOINTS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = valleypoints(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   valleypoints
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 18 Nov 2009
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: valleypoints.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DuneErosionLibrary/engines/valleypoints.m $
% $Keywords: $

%% parse input
OPT = struct(...
    'SeawardBoundary',[],...
    'LandwardBoundary',[]);

[OPT Set] = setproperty(OPT,varargin);
if ~Set.SeawardBoundary
    OPT.SeawardBoundary = max(xInitial);
end
if ~Set.LandwardBoundary
    OPT.LandwardBoundary = min(xInitial);
end


%%
[xcross, zcross, xInitial, zInitial] = findCrossings(xInitial, zInitial, xInitial([1 end]), ones(2,1)*WL, 'keeporiginalgrid');  % intersections of initial profile with WL

x0except = [];
if zInitial(xInitial==min(xInitial))< WL
    % landward tail of the profile, being below water level, is dealt with
    % as exception
   x0except = [min(xInitial) min(xcross)] ;
end

% remove points outside boundaries
xcross = xcross(xcross>OPT.LandwardBoundary & xcross<max(xcross)); % possible intersections of WL with part initial profile seaward of x00min and landward of x0max
xcross = xcross(xcross<OPT.SeawardBoundary & xcross<max(xcross)); % possible intersections of WL with part initial profile seaward of x00min and landward of x0max

% Seperate up and down crossings
xcrossid = find(ismember(xInitial,xcross));
xcrossup = zInitial(xcrossid+1)>WL;
downs = xcross(diff([1; xcrossup])==-1);
ups = xcross(diff([1; xcrossup])==1);
x0except = flipud([x0except; [downs(1:length(ups)), ups]]);
if isempty(x0except)
    % to avoid problems with a variable of size 0x1
    x0except=[];
end

