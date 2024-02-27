function fh = UCIT_plotTransectOverview(datatype,varargin)
%UCIT_PLOTTRANSECTOVERVIEW   this routine displays all transect outlines
%
% This routine displays all transect outlines.
%              
%  <figure_handle> = UCIT_plotGridOverview(datatype)
%
% see also ucit_netcdf, UCIT_getInfoFromPopup

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld       
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
%       Ben.deSonneville@Deltares.nl	
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

OPT.refreshonly = 0;
OPT = setproperty(OPT,varargin{:});

%% get metadata (either from the console or the database)

d   = UCIT_getMetaData(1);

%% now plot the transectcontours gathered in d

if ~isempty(d)
    UCIT_plotFilteredTransectContours(d);
end

%% Adjust axis and labels

axis equal;
axis([d.axes])
ylabel('Northing [m]')
xlabel('Easting [m]')

%% Make figure visible

fh = findobj('tag','mapWindow');
figure(fh);
set(fh,'visible','on');

