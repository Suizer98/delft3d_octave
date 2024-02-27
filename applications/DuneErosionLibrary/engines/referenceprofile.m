function [xReferenceProfile zReferenceProfile] = referenceprofile(varargin)
%SIMPLEPROFILE  routine to create standard simplified cross-shore profile
%
%   Routine to create a simplified cross-shore profile which is more or less
%   representative for a large part of the Dutch coast. Minimum and maximim
%   of both x and z can be specified by keyword-value pairs
%
%   Syntax:
%   [xReferenceProfile zReferenceProfile] = simpleprofile(varargin)
%
%   Input:
%   varargin = series of keyword-value pairs to set
%       'xmin' - landward boundary
%       'xmax' - seaward boundary
%       'zmin' - lower boundary
%       'zmax' - upper boundary
%
%   Output:
%   xReferenceProfile        = column vector of x coordinates
%   zReferenceProfile        = column vector of z coordinates
%
%   Example
%   simpleprofile
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

% $Id: referenceprofile.m 1948 2009-11-19 15:18:40Z geer $
% $Date: 2009-11-19 23:18:40 +0800 (Thu, 19 Nov 2009) $
% $Author: geer $
% $Revision: 1948 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DuneErosionLibrary/engines/referenceprofile.m $
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
xReferenceProfile = [5.625 55.725 230.625]';
zReferenceProfile = [3 0 -3]';

if OPT.zmax > max(zReferenceProfile) && OPT.xmin < min(xReferenceProfile)
    % construct dune front
    duneFrontPolynomialCoefficients = [-2.5 13.125];
    xReferenceProfile = [polyval(duneFrontPolynomialCoefficients, OPT.zmax); xReferenceProfile];
    zReferenceProfile = [OPT.zmax; zReferenceProfile];
end

if OPT.xmin < min(xReferenceProfile)
    % construct dune top
    xReferenceProfile = [OPT.xmin; xReferenceProfile];
    zReferenceProfile = [OPT.zmax; zReferenceProfile];
end

[xMinimumHeightConstraint...
    zMinimumHeightConstraint...
    xMaximumLengthConstraint...
    zMaximumLengthConstraint] = deal([]);
if OPT.zmin < min(zReferenceProfile)
    % construct landward part based on zmin
    landPolynomialCoefficients = [-150 -219.3750];
    xMinimumHeightConstraint = [xReferenceProfile; polyval(landPolynomialCoefficients, OPT.zmin)];
    zMinimumHeightConstraint = [zReferenceProfile; OPT.zmin];
end

if OPT.xmax > max(xReferenceProfile)
    % construct seaward part based on xmax
    seawardPolynomialCoefficients = [-1/150 -1.4625];
    xMaximumLengthConstraint = [xReferenceProfile; OPT.xmax];
    zMaximumLengthConstraint = [zReferenceProfile; polyval(seawardPolynomialCoefficients, OPT.xmax)];
end

% choose the appropriate seaward end
if any(strcmpi(varargin, 'zmin')) && ~isempty(OPT.zmin) && ~any(strcmpi(varargin, 'xmax'))
    % seaward end is determined by zmin input
    [xReferenceProfile zReferenceProfile] = deal(xMinimumHeightConstraint, zMinimumHeightConstraint);
elseif ~isempty(OPT.xmax)
    % searward end is determined by xmax (input?)
    [xReferenceProfile zReferenceProfile] = deal(xMaximumLengthConstraint, zMaximumLengthConstraint);
end

if any(strcmpi(varargin, 'xmax')) && ~isempty(OPT.xmax) && ~any(strcmpi(varargin, 'zmin'))
    [xReferenceProfile zReferenceProfile] = deal(xMaximumLengthConstraint, zMaximumLengthConstraint);
elseif ~isempty(OPT.zmin)
    [xReferenceProfile zReferenceProfile] = deal(xMinimumHeightConstraint, zMinimumHeightConstraint);
end