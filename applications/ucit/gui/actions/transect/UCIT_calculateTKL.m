function calculateTKL()
%UCIT_calculateTKL computes the volume based coastal indicator TKL
%
% input: through UCIT GUI
%
% output: through UCIT GUI
%
%
%   See also jarkus_getTKL

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

[check]=UCIT_checkPopups(1, 4);
if check == 0
    return
end

%% get info from UCIT GUI
targetyear = UCIT_getInfoFromPopup('TransectsSoundingID');
areaname = UCIT_getInfoFromPopup('TransectsArea');
transectID = UCIT_getInfoFromPopup('TransectsTransectID');
areacode = jarkus_areaName2AreaCode(areaname);

%% prepare figure
guiH = findobj('tag','UCIT_mainWin');

if get(findobj(guiH,'tag','UCIT_holdtimeFigure'),'value')==0|isempty(findobj('tag','plotWindowTKL'))
    if ~isempty(findobj('tag','plotWindowTKL'))
        delete(findobj('tag','plotWindowTKL'))
    end
    
    fh = figure('tag','plotWindowTKL');cla;
    RaaiInformatie=['UCIT - TKL analysis -  Area: ' areaname '  Transect: ' transectID '  Time: ' num2str(targetyear)];
    set(fh,'Name', RaaiInformatie,'NumberTitle','Off','Units','normalized');
    ah=axes;
    [fh,ah] = UCIT_prepareFigureN(0, fh, 'UR', ah);
    delete(ah)
else
    fh = figure(findobj('tag','plotWindowTKL'));
    hold on;
end

%% get TKL
targetyear = str2double(datestr(targetyear,'yyyy'));
new_transectID = areacode*1000000 + str2double(transectID);
[TKL] = jarkus_getTKL(targetyear, new_transectID,'plot');

