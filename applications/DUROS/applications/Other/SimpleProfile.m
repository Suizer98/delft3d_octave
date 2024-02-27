function [x z] = SimpleProfile(varargin)
%SIMPLEPROFILE  routine to create standard simplified cross-shore profile
%
%   Routine to create a simplified cross-shore profile which is more or less
%   representative for a large part of the Dutch coast. Minimum and maximim
%   of both x and z can be specified by keyword-value pairs
%
%   Syntax:
%   [x z] = SimpleProfile(varargin)
%
%   Input:
%   varargin = series of keyword-value pairs to set
%       'xmin' - landward boundary
%       'xmax' - seaward boundary
%       'zmin' - lower boundary
%       'zmax' - upper boundary
%
%   Output:
%   x        = column vector of x coordinates
%   z        = column vector of z coordinates
%
%   Example
%   SimpleProfile
%
%   See also setproperty

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 20 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: SimpleProfile.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/applications/Other/SimpleProfile.m $
% $Keywords:

%% default options
% field names are automatically recognised as keywords
OPT = struct(...
	'xmin', -250,...  % landward boundary
	'xmax', [],...    % seaward boundary
	'zmin', -20,...   % lower boundary
	'zmax', 15 ...    % upper boundary
    );

% set options based on input from varargin (PropertyName-PropertyValue pairs)
OPT = setproperty(OPT, varargin{:});

%%
x = [5.625 55.725 230.625]';
z = [3 0 -3]';

if OPT.zmax > max(z) && OPT.xmin < min(x)
    % construct dune front
    pDunezx = [-2.5 13.125];
    x = [polyval(pDunezx, OPT.zmax); x];
    z = [OPT.zmax; z];
end

if OPT.xmin < min(x)
    % construct dune top
    x = [OPT.xmin; x];
    z = [OPT.zmax; z];
end

[x_zmin z_zmin x_xmax z_xmax] = deal([]);
if OPT.zmin < min(z)
    % construct seaward part based on zmin
    pshorezx = [-150 -219.3750];
    x_zmin = [x; polyval(pshorezx, OPT.zmin)];
    z_zmin = [z; OPT.zmin];
end

if OPT.xmax > max(x)
    % construct seaward part based on xmax
    pshorexz = [-1/150 -1.4625];
    x_xmax = [x; OPT.xmax];
    z_xmax = [z; polyval(pshorexz, OPT.xmax)];
end

% choose the appropriate seaward end
if any(strcmpi(varargin, 'zmin')) && ~isempty(OPT.zmin) && ~any(strcmpi(varargin, 'xmax'))
    [x z] = deal(x_zmin, z_zmin);
elseif ~isempty(OPT.xmax)
    [x z] = deal(x_xmax, z_xmax);
end

if any(strcmpi(varargin, 'xmax')) && ~isempty(OPT.xmax) && ~any(strcmpi(varargin, 'zmin'))
    [x z] = deal(x_xmax, z_xmax);
elseif ~isempty(OPT.zmin)
    [x z] = deal(x_zmin, z_zmin);
end