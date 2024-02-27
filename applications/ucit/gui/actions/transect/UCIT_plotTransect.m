function UCIT_plotTransect(d)
%PLOTTRANSECT   routine plots transect from structure d
%
% input:
%   d = basic McDatabase datastructure for transects
% output:
%   function has no output
%
%   See also getPlot

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Ben de Sonneville
%
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
tic
datatypes = UCIT_getDatatypes;
url = datatypes.transect.urls{find(strcmp(UCIT_getInfoFromPopup('TransectsDatatype'),datatypes.transect.names))};

if nargin==0
    [check]=UCIT_checkPopups(1, 4);
    if check == 0
        return
    end

%     clearvars -global;
    clear global

    year = UCIT_getInfoFromPopup('TransectsSoundingID');
    d = jarkus_readTransectDataNetcdf(url, UCIT_getInfoFromPopup('TransectsArea'),UCIT_getInfoFromPopup('TransectsTransectID'),year(end-3:end));
    d.zi=squeeze(d.zi);
    d.ze=squeeze(d.ze);
    if ~all(isnan(d.ze))
        UCIT_getPlot(d);
    else
        errordlg(['Transect: ', d.transectID,'  Year: ',num2str(d.year) ' does not contain data']);
    end
else
    if ~all(isnan(d.ze))
        UCIT_getPlot(d);
    else
        errordlg(['Transect: ', d.transectID,'  Year: ',num2str(d.year) ' does not contain data']);
    end
end

if ~isempty(findobj('tag','mapWindow'))
    UCIT_showTransectOnOverview
end
toc