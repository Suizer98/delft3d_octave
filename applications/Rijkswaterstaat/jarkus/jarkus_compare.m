function varargout = jarkus_compare(varargin)
%JARKUS_COMPARE  Compare OpenEarth jarkus data to another data source
%
%   This routine compares jarkus transect data from OpenEarth to
%   corresponding transects from another data source, for checking
%   purposes.
%
%   Syntax:
%   varargout = jarkus_compare(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   jarkus_compare
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 25 May 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: jarkus_compare.m 6715 2012-06-29 11:39:34Z heijer $
% $Date: 2012-06-29 19:39:34 +0800 (Fri, 29 Jun 2012) $
% $Author: heijer $
% $Revision: 6715 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_compare.m $
% $Keywords: $

%%
OPT = struct(...
    'id', [7003925 7004475],...
    'year', [],...
    'var2compare', 'altitude',...
    'alt_source_fun', @(z) z,...
    'alt_source_inputargs', '',...
    'alt_source_name', '');

OPT = setproperty(OPT, varargin{:});

% if nargin==0;
%     varargout = {OPT};
%     return;
% end

%% obtain OpenEarth JARKUS data
% find the available identifiers based on the request
if isempty(OPT.id)
    tmp = jarkus_transects(...
        'output', {'id'});
else
    tmp = jarkus_transects(...
        'id', OPT.id,...
        'output', {'id'});
end
id = tmp.id;
if isempty(id)
    warning('No data available in the requested range.')
    return
end

% find the available years based on the request
if isempty(OPT.year)
    tmp = jarkus_transects(...
        'output', {'time'});
else
    tmp = jarkus_transects(...
        'year', OPT.year,...
        'output', {'time'});
end
datevecs = datevec(datenum(1970,1,1) + tmp.time);
years = datevecs(:,1)'; % transposing is because jarkus_transects needs a row vector

% obtain the selected data from OpenEarth
tr = jarkus_transects(...
    'id', id,...
    'year', years,...
    'output', {'id' 'year' 'cross_shore' OPT.var2compare});
dataOE = tr.(OPT.var2compare);

%% obtain data from alternative source
if isempty(OPT.alt_source_inputargs)
    dataALT = feval(OPT.alt_source_fun,...
        'id', id,...
        'year', years,...
        'cross_shore', tr.cross_shore);
else
    dataALT = feval(OPT.alt_source_fun,...
        OPT.alt_source_inputargs{:});
end

%% make comparison
dz = dataOE - dataALT(:,[1 end],:);
ncompared = sum(~isnan(dz(:)));
nequal = sum(dz(:)==0);
dz(isnan(dz)) = 0;
ndifferent = sum(dz(:)~=0);
maxdz = max(dz(:));
mindz = min(dz(:));

for iyear = 1:length(years)
    for iid = 1:length(id)
        tmpdz = squeeze(dz(iyear,iid,:));
        if any(tmpdz ~= 0)
            x = tr.cross_shore(tmpdz ~= 0);
            dzmax = max(abs(tmpdz));
            xmin = min(x);
            xmax = max(x);
            xint = xmin:5:xmax;
            zOE = squeeze(dataOE(iyear, iid, :));
            zOE = interp1(tr.cross_shore(~isnan(zOE)), zOE(~isnan(zOE)), xint);
            zALT = squeeze(dataALT(iyear, iid, :));
            zALT = interp1(tr.cross_shore(~isnan(zALT)), zALT(~isnan(zALT)), xint);
            [V result] = getVolume(xint, zOE,...
                'x2', xint,...
                'z2', zALT);
            fprintf('%7i\t%4i\t%4i\t%4i\t%.2f\n', id(iid), years(iyear), xmin, xmax, V);
        end
        yearmax = max(abs(tmpdz(:)));
        if yearmax > .1
%             iid = max(tmpdz,[],2) == yearmax | min(tmpdz,[],2) == -yearmax;
            figure;
            OEh = plot(tr.cross_shore, squeeze(dataOE(iyear,iid,:)), '-+b',...
                'DisplayName', 'OpenEarth');
            hold on
            ALTh = plot(tr.cross_shore, squeeze(dataALT(iyear,iid,:)), '-r',...
                'DisplayName', OPT.alt_source_name);
            legend('toggle')
            title(sprintf('transect %i, year %i (max diff = %.1f m)', id(iid), years(iyear), max(abs(tmpdz))))
        end
    end
end
