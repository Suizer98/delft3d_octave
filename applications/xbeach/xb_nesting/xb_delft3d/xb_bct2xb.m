function [tidefile tidelen tideloc] = xb_bct2xb(fname, varargin)
%XB_BCT2XB  Converts Delft3D-FLOW BCT file to an XBeach tide file
%
%   Converts Delft3D-FLOW BCT file to an XBeach tide file, possibly
%   cropping the timeseries.
%
%   Syntax:
%   [tidefile tidelen tideloc] = xb_bct2xb(fname, varargin)
%
%   Input:
%   fname     = Path to BCT file
%   varargin  = tidefile:       Path to output file
%               tstart:         Datenum indicating simulation start time
%               tlength:        Datenum indicating simulation length
%
%   Output:
%   tidefile  = Path to output file
%   tidelen   = Length of timeseries in output file
%   tideloc   = Number of locations in output file
%
%   Example
%   [tidefile tidelen tideloc] = xb_bct2xb(fname)
%   [tidefile tidelen tideloc] = xb_bct2xb(fname, 'tstart', datenum('2007-11-05'))
%
%   See also xb_delft3d_flow, xb_sp22xb

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 14 Feb 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_bct2xb.m 4036 2011-02-15 15:32:35Z hoonhout $
% $Date: 2011-02-15 23:32:35 +0800 (Tue, 15 Feb 2011) $
% $Author: hoonhout $
% $Revision: 4036 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_nesting/xb_delft3d/xb_bct2xb.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'tidefile', 'tide.txt', ...
    'tstart', 0, ...
    'tlength', Inf ...
);

OPT = setproperty(OPT, varargin{:});

tidefile = OPT.tidefile;

%% convert bct file

info = bct_io('read', fname);

tstamp = datenum(num2str(info.Table(1).ReferenceTime), 'yyyymmdd');

t = tstamp+info.Table(1).Data(:,1)/1440;

c1 = info.Table(1).Data(:,2);
c2 = info.Table(1).Data(:,3);

t = (t-OPT.tstart);

tstart = find(t>=0, 1, 'first');
tstop = find(t<OPT.tlength, 1, 'last');

if length(t) > tstop; tstop = tstop + 1; end;

dat(:,1) = t(tstart:tstop)*86400;
dat(:,2) = c1(tstart:tstop);
dat(:,3) = c2(tstart:tstop);

save(tidefile, '-ascii', 'dat');

tidelen = size(dat,1);
tideloc = size(dat,2)-1;