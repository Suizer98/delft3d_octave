function UCIT_sandBalanceInPolygon
%UCIT_SANDBALANCEINPOLYGON   computes volume change for a given polygon and settings
%
%   syntax:
%       UCIT_sandBalanceInPolygon
%
%   input:
%       function has no input
%
%   output:
%       function has no output
%
%   See also UCIT_findCoverage, UCIT_plotDataInPolygon, grid_orth_getDataInPolygon

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%
%       Ben de Sonneville
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

warningstate = warning;
warning off

datatype = UCIT_getInfoFromPopup('GridsDatatype');

%% Specify polygon
OPT.polygon         = [];
curdir    = pwd;

%% Select in either grid plot or grid overview plot
mapW = findobj('tag','gridPlot');
if isempty(mapW)
    if isempty(findobj('tag','gridOverview')) %|| ~any(ismember(get(axes, 'tag'), {datatype}))
        fh = UCIT_plotGridOverview(datatype,'refreshonly',0);
    else
        fh = UCIT_plotGridOverview(datatype,'refreshonly',1);
    end
else
    fhs = findobj('tag','gridPlot');
    fh = figure(fhs(1)); figure(fh);
end

%% select or load polygon
try delete(findobj(ah,'tag','selectionpoly'));  end %#ok<*TRYNC> delete any remaining poly

% if no polygon is available yet draw one
if isempty(OPT.polygon)
    % make sure the proper axes is current
    try axes(ah); end
    
    jjj = menu({'Zoom to your place of interest first.',...
        'Next select one of the following options.',...
        'Finish clicking of a polygon with the <right mouse> button.'},...
        '1. click a polygon',...
        '2. click a polygon and save to file',...
        '3. load a polygon from file',...
        '4. select directory with polygons');
    
    if jjj<3
        % draw a polygon using polydraw making sure it is tagged properly
        disp('Please click a polygon from which to select data ...')
        [x,y] = polydraw('g','linewidth',2,'tag','selectionpoly');
        plot(x,y,'g','linewidth',2,'tag','selectionpoly');
    elseif jjj==3
        % load and plot a polygon
        [OPT.polyname, OPT.polydir] = uigetfile({'*.ldb','Delft3D landboundary file (*.ldb)'},'Pick a landboundary file');
        [x,y]=landboundary('read',fullfile(OPT.polydir,OPT.polyname));
        x = x';
        y = y';
    end
    
    % save polygon
    if jjj==2
        [OPT.polyname, OPT.polydir] = uiputfile({'*.ldb','Delft3D landboundary file (*.ldb)'},'Specifiy a landboundary file',...
            ['polygon_',datestr(now)]);
        landboundary('write',fullfile(OPT.polydir,OPT.polyname),x,y);
    end
    
    % save temporary polygon
    if jjj==1
        OPT.polyname  =  ['polygon_' datestr(now,30),'.ldb'];
        OPT.polydir = [getenv('TEMP') filesep 'polygons'];
        mkdir([getenv('TEMP') filesep 'polygons']);
        landboundary('write',fullfile(OPT.polydir,OPT.polyname),x,y);
    end
    
    if jjj == 4
        OPT.polydir = uigetdir(pwd,'Select folder with polygons');
        fns = dir(OPT.polydir);
        fns(strcmp({fns.name},'.')|strcmp({fns.name},'..'))= [];
        OPT.polyname = {fns.name};
    else
        % combine x and y in the variable polygon and close it
        OPT.polygon = [x' y'];
        OPT.polygon = [OPT.polygon; OPT.polygon(1,:)];
        OPT.polyname = {OPT.polyname};
    end
end

%% select folder for results
if jjj == 1
    dname = getenv('TEMP');
else
    dname = uigetdir(pwd,'Select folder to store data');
end
cd(dname);

%% confirm sand balance settings
prompt    = {'Minimal coverage [%]','Search window [months]','First year','Last year'};
dlg_title = 'Sand balance settings';
num_lines = 1;
def       = {'10',UCIT_getInfoFromPopup('GridsInterval'),'2000','2005'};
answer    = inputdlg(prompt,dlg_title,num_lines,def);

%% arrange input in OPT structure
OPT.datatype        = datatype;
OPT.min_coverage    =  str2double(answer{1});
OPT.thinning        =  1;
OPT.timewindow      =  str2double(answer{2}); % in months
OPT.inputyears      = [str2double(answer{3}) : str2double(answer{4})];

%% get sandbalance
UCIT_getSandBalance(OPT)

warning(warningstate)

cd(curdir);

%% EOF