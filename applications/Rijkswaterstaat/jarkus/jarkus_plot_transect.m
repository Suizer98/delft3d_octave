function varargout = jarkus_plot_transect(varargin)
%JARKUS_PLOT_TRANSECT  Plot JARKUS transect
%
%   Plot one or multiple transects of one or multiple years. Specify 'id' 
%   and 'year' as propertynam-propertyvalue pairs. The plot handle can be 
%   obtained as output argument.
%
%   Syntax:
%   varargout = jarkus_plot_transect(varargin)
%
%   Input:
%   varargin  = propertyname-propertyvalue pairs as suitable for
%               jarkus_transects function
%
%   Output:
%   varargout = plot handle
%
%   Example
%   jarkus_plot_transect('id', 7005375, 'year', 2010)
%
%   See also jarkus_transects

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
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
% Created: 18 Feb 2011
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: jarkus_plot_transect.m 8268 2013-03-04 16:24:32Z heijer $
% $Date: 2013-03-05 00:24:32 +0800 (Tue, 05 Mar 2013) $
% $Author: heijer $
% $Revision: 8268 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_plot_transect.m $
% $Keywords: $

%% defaults and input check
% check number of input arguments
narginchk(1, Inf)

if isscalar(varargin) && isstruct(varargin{1})
    % structure input argument is assumed to be created by jarkus_transects
    tr = varargin{1};
else
    % transect structure is obtained by jarkus_transects
    try
        tr = jarkus_transects(varargin{:});
    catch E
        if strcmp(E.identifier, 'MATLAB:Java:GenericException')
            error('Memory problems occured, confine your selection by specifying "id" and "year".')
        end
    end
end

%%
required_fields = {'cross_shore' 'altitude' 'time', 'id'};
if all(ismember(required_fields, fieldnames(tr)))
    % derive the size (dimensions) of the altitude array
    dims = size(tr.altitude);
    % convert altitude to a 2 dimensional array
    altitude = reshape(tr.altitude, prod(dims(1:2)), dims(3));
    % create identifier with cross-shore points where any data is available
    nnid = sum(~isnan(altitude),1) ~= 0;
    % plot all transects at once (multiple years and/or transects)
    ph = plot(tr.cross_shore(nnid), altitude(:,nnid));
    % creat displaynames to be used in legend
    [ids, years] = meshgrid(tr.id, year((datenum(1970,1,1) + tr.time)));
    ids = reshape(ids, prod(dims(1:2)), 1);
    years = reshape(years, prod(dims(1:2)), 1);
    if isscalar(unique(ids))
        % put transect number in title
        title(sprintf('transect %i', unique(ids)));
        % put years in legend
        displayname = textscan(sprintf('%i\n', years'), '%s', dims(1), 'delimiter', '\n');
    elseif isscalar(unique(years))
        % put year in title
        title(sprintf('year %i', unique(years)));
        % put transect number in legend
        displayname = textscan(sprintf('transect %i\n', ids'), '%s', dims(2), 'delimiter', '\n');
    else
        % put both transect numbers and years in legend
        displayname = textscan(sprintf('transect %i (%i)\n', [ids years]'), '%s', prod(dims(1:2)), 'delimiter', '\n');
    end
    set(ph, {'Displayname'}, displayname{:});
    % turn on legend
    legend show
    % add axis labels
    xlabel('Cross-shore coordinate [m]')
    ylabel('Altitude [m] w.r.t. NAP')
else
    error(['The following required fields are not found: ' sprintf('"%s" ', required_fields{~ismember(required_fields, fieldnames(tr))})])
end

if nargout > 0
    varargout = {ph};
end