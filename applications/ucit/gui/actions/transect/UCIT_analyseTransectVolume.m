function UCIT_analyseTransectVolume()
%UCIT_ANALYSEVOLUME   routine plots time stack of transect
%
% input: select in gui
%
%
%
%
% output: volume
%
%
% syntax:
%
%
%   See also
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

[check]=UCIT_checkPopups(1, 4);
if check == 0
    return
end

c=load('ucit_icons.mat');

%% load relavant data
datatypes = UCIT_getDatatypes;
url = datatypes.transect.urls{find(strcmp(UCIT_getInfoFromPopup('TransectsDatatype'),datatypes.transect.names))};
year = str2double(datestr(UCIT_getInfoFromPopup('TransectsSoundingID'),10));
d = jarkus_readTransectDataNetcdf(url, UCIT_getInfoFromPopup('TransectsArea'),UCIT_getInfoFromPopup('TransectsTransectID'),year);
d.zi = squeeze(d.zi);
d.ze = squeeze(d.ze);

if isempty(findobj('tag','analyseTransectWindow')) % this means that there is no figure present yet

    prompt = {'UpperBoundary','LowerBoundary','LandwardBoundary','SeawardBoundary'};
    dlg_title = 'Input boundaries';
    num_lines = 1;
    def = {'10','-10',num2str(min(d.xi(~isnan(d.zi)))+ 100 ),num2str(max(d.xi(~isnan(d.zi))) - 100)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    UpperBoundary = str2double(answer{1});
    LowerBoundary = str2double(answer{2});
    LandwardBoundary = str2double(answer{3});
    SeawardBoundary = str2double(answer{4});
    Boundaries = [UpperBoundary,LowerBoundary,LandwardBoundary,SeawardBoundary];

    %% store results plus additional info in guidata
    results.xold = d.xi(~isnan(d.zi));
    results.zold = d.zi(~isnan(d.zi));
    results.Boundaries = Boundaries;
    
else
    results = get(findobj('tag','analyseTransectWindow'),'userdata');
    UpperBoundary = results.Boundaries(1);
    LowerBoundary = results.Boundaries(2);
    LandwardBoundary = results.Boundaries(3);
    SeawardBoundary = results.Boundaries(4);
    close(findobj('tag','analyseTransectWindow'));
end

%% Prepare figure
RaaiInformatie=['UCIT - Transect analysis tool'];
fh=figure('tag','analyseTransectWindow');clf;
set(fh,'Name', RaaiInformatie,'NumberTitle','Off','Units','normalized');
ah=axes;

[fh,ah] = UCIT_prepareFigureN(2, fh, 'UL', ah);

%% Add additional buttons
tbh = findall(fh,'Type','uitoolbar');

% objTag = 'TransectsSoundingID';
% adj = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Year before');
% set(adj,'ClickedCallback','UCIT_next(-1,''TransectsSoundingID'')');
% set(adj,'Tag','SeawardBoundary');
% set(adj,'cdata',c.ico.arrowleft_green16);
% 
% adj = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Next year');
% set(adj,'ClickedCallback','UCIT_next(1,''TransectsSoundingID'')');
% set(adj,'Tag','LandwardBoundary');
% set(adj,'cdata',c.ico.arrowright_green16);

% set(gca,'xdir','reverse');

set(findobj('tag','analyseTransectWindow'),'userdata',results);

try
    Volume = jarkus_getVolumeFast(d.xi(~isnan(d.zi)),d.zi(~isnan(d.zi)),UpperBoundary,LowerBoundary,LandwardBoundary,SeawardBoundary,'plot');
catch
    errordlg('Check your boundaries')
end

title([num2str(year) '; Volume = ', num2str(Volume, '% 9.2f'),' m^3']);
disp([num2str(year) '; Volume = ', num2str(Volume, '% 9.2f'),' m^3']);

end



