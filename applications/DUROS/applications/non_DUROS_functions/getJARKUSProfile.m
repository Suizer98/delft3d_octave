function [x z] = getJARKUSProfile(year, area, transect, varargin)
%GETJARKUSPROFILE  get JARKUS profile from JARKUS repository from year, area name & transect number
%
%     [x z] = getJARKUSProfile(year, area, transect, varargin)
%
%   retrieves JARKUS profile from JARKUS repository based on a four digit
%   representation of the year of measurement, a full name of the area of
%   measurement (see RWS_KUSTVAK) and a four digit representation of the
%   transect number.
%
%   Input:
%   year        = four digit representation of year of measurement
%   area        = full name of area of measurement
%   transect    = four digit representation of transect number
%   varargin    = 'PropertyName' PropertyValue pairs (optional)
%   
%                 'repository'  = url where the JARKUS repository can be
%                                   found. By default this is the online
%                                   Deltares repository, but it can also be
%                                   a local copy.
%
%   Output:
%   x           = array with x-coordinates of retrieved profile
%   z           = array with z-coordinates of retrieved profile
%
%   Example
%   [x z] = getJARKUSProfile(year, area, transect)
%
%   See also: rws_kustvak

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       B.M. (Bas) Hoonhout
%
%       Bas.Hoonhout@Deltares.nl	
%
%       Deltares
%       P.O. Box 177 
%       2600 MH Delft 
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

% Created: 15 Mei 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id: getJARKUSProfile.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/applications/non_DUROS_functions/getJARKUSProfile.m $

%% settings

OPT = struct( ...
    'repository', 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc' ...
);

OPT = setproperty(OPT, varargin{:});

%% retrieve JARKUS profile from repository
% read matching records from respository based on year, area name and
% transect number

yearID     = nc_varget(OPT.repository, 'year') == year;
areaID     = nc_varget(OPT.repository, 'areacode') == rws_kustvak(area);
transectID = nc_varget(OPT.repository, 'coastward_distance') == transect;

% identify unique transect based on combination of both area and transect
% number

transectID = areaID & transectID;

%% read profile

x = nc_varget(OPT.repository, 'seaward_distance');
z = nc_varget(OPT.repository, 'height', ...
    [find(yearID, 1, 'first') - 1 find(transectID, 1, 'first') - 1 0], ...
    [sum(yearID) sum(transectID) length(x)]);

%% remove NaN's

idxs = find(isnan(z));
x(idxs) = []; z(idxs) = [];