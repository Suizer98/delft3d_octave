function specs = xb_get_profilespecs(x,z,varargin)
%XB_GET_PROFILESPECS  Determines a variety of profile characteristics from a dune profile
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_get_profilespecs(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_get_profilespecs
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 26 Jan 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_get_profilespecs.m 8605 2013-05-10 10:35:08Z hoonhout $
% $Date: 2013-05-10 18:35:08 +0800 (Fri, 10 May 2013) $
% $Author: hoonhout $
% $Revision: 8605 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_analysis/xb_get_profilespecs.m $
% $Keywords: $

%% read settings

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% determine dune front

front = struct( ...
    'length',       zeros(size(x,1),1), ...
    'height',       zeros(size(x,1),1), ...
    'slope',        zeros(size(x,1),1), ...
    'location_h',   zeros(size(x,1),2), ...
    'location_v',   zeros(size(x,1),2)      );

for i = 1:size(x,1)
    
    dzdx = diff(z(i,:))./diff(x(i,:));

    p = stat_freqexc_get(1:length(dzdx),dzdx,'horizon',OPT.ngidmax);

    [m ii] = max([p.peaks.nmax]);
    [m jj] = max(abs([p.peaks(ii).maxima.duration]));

    i1 = p.peaks(ii).maxima(jj).start;
    i2 = p.peaks(ii).maxima(jj).end;
    
    front.location_h(i,:) = x(i,[i1 i2]);
    front.location_v(i,:) = z(i,[i1 i2]);
    front.length(i)       = abs(diff(front.location_h(i,:)));
    front.height(i)       = abs(diff(front.location_v(i,:)));
    front.slope(i)        = front.height(i)/front.length(i);
end

%% determine beach

beach = struct( ...
    'length',       zeros(size(x,1),1), ...
    'height',       zeros(size(x,1),1), ...
    'slope',        zeros(size(x,1),1), ...
    'location_h',   zeros(size(x,1),2), ...
    'location_v',   zeros(size(x,1),2)      );

for i = 1:size(x,1)
    
    i1 = 1;
    i2 = find(x(i,:)==front.location_h(i,1),1,'first');
    
    beach.location_h(i,:) = x(i,[i1 i2]);
    beach.location_v(i,:) = z(i,[i1 i2]);
    beach.length(i)       = abs(diff(beach.location_h(i,:)));
    beach.height(i)       = abs(diff(beach.location_v(i,:)));
    beach.slope(i)        = beach.height(i)/beach.length(i);
end

%% determine crest

crest = struct( ...
    'maximum',      zeros(size(x,1),1), ...
    'location',     zeros(size(x,1),1)      );

for i = 1:size(x,1)
    [crest.maximum(i) i1] = max(z(i,:));
    crest.location(i)     = x(i,i1);
end

%% prepare output

specs = struct(     ...
    'profile', struct( ...
        'x', x,     ...
        'z', z),    ...
    'beach', beach, ...
    'front', front, ...
    'crest', crest      );
    
