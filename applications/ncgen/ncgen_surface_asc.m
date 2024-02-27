function OPT = ncgen_surface_asc(varargin)
%NCGEN_SURFACE_ASC  process snapshot files into (x,y,t) netCDF tiles
%
%   More detailed description goes here.
%
%   Syntax:
%   OPT = ncgen_surface_xyz(varargin)
%
%   Input:
%   varargin =
%
%   Output:
%   OPT      =
%
%   Example
%   ncgen_surface_xyz
%
%   See also: NCGEN

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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
% Created: 24 Apr 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: ncgen_surface_asc.m 7469 2012-10-12 10:05:04Z boer_g $
% $Date: 2012-10-12 18:05:04 +0800 (Fri, 12 Oct 2012) $
% $Author: boer_g $
% $Revision: 7469 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ncgen/ncgen_surface_asc.m $
% $Keywords: $

%% Define schemaFcn, readFcn and writeFcn
% Define appropriate functions dependant on the dataset as ex[plained
% above. Note that each function requires a fixed set of inputs. 
schemaFcn   = @(OPT)              ncgen_schemaFcn_surface  (OPT);
readFcn     = @(OPT,writeFcn,fns) ncgen_readFcn_surface_asc(OPT,writeFcn,fns);
writeFcn    = @(OPT,data)         ncgen_writeFcn_surface   (OPT,data);

% by passing these functions to the main function, an OPT structure is
% returned that can then be inspecdted to see which properties can be set.
if nargin == 0
    OPT         = ncgen_mainFcn(schemaFcn,readFcn,writeFcn);
    return
end

OPT = ncgen_mainFcn(schemaFcn,readFcn,writeFcn,varargin{:});

