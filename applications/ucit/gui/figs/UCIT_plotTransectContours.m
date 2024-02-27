function UCIT_plotTransectContours(d) %#ok<INUSD>
%UCIT_PLOTFILTEREDTRANSECTCONTOURS  plots transect outlines in overview
% figure of UCIT gui 
%
%
%   Syntax:
%   varargout = 
%
%   Input:
%   varargin  = metadata strucure (d) and axis limits of Transect Overview
%   figure
%
%   Output:
%   none
%

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

if ~isempty(findobj('tag','mapWindow'))
    close(findobj('tag','mapWindow'));
end

fh=figure('tag','mapWindow');clf;
ah=axes;
[fh] = UCIT_prepareFigureN(0, fh, 'LL', ah, @UCIT_plotTransectContours, {get(findobj('tag','UCIT_mainWin'),'Userdata'), axis(ah)}, @UCIT_plotTransectContours, {get(findobj('tag','UCIT_mainWin'),'Userdata'), axis(ah)});
set(fh,'name','UCIT - Transect overview');
% xlabel('x-distance [m]')
% ylabel('y-distance [m]', 'Rotation', 270, 'VerticalAlignment', 'top')
set(gca, 'fontsize',8);
handles = guidata(fh);

axis equal;
plotLandboundary(d(1).datatypeinfo,1);
hold on;
box on

[handles.ph,handles.ph2] = drawData(fh, d);

guidata(fh,handles);

%%
function [ph, ph2] = drawData(fh, d, ph, ph2) %#ok<INUSL>

if nargin == 4
     %#ok<TRYNC>
        %         delete(ph{:});
        %         delete(ph2{:});
        %Find all rays
        rayH=findobj(gca,'type','line','LineStyle','-');
        dpTs=strvcat(get(rayH,'tag'));
        for ii=1:size(dpTs,1);
            if strfind(dpTs(ii,:),'_')
                res(ii)=1;
            end
        end
        rayH=rayH(find(res==1));
        delete(rayH);
        drawnow
    
end

title ({''});
drawnow
[ph, ph2] = displayFilteredTransects(d);

%%
function [ph, ph2] = displayFilteredTransects(d)

%% get info needed to construct a proper tag

soundingID   = repmat({'01012001'},size(d.area));
separator    = repmat({'_'},size(d.area));
colors1      = repmat({'color'},size(d.area));
colors2      = repmat({'r'},size(d.area));
tags1        = repmat({'tag'},size(d.area));
tags2        = cellfun(@horzcat, d.datatypeinfo,separator,d.area,separator,d.transectID,separator,d.soundingID,'UniformOutput',false);

[xs, ys, zs] = deal(repmat({[1;1]}, size(d.area)));
tic
for i = 1:length(d.area)
    xs{i} =  [d.contour(i,1);d.contour(i,2)];
    ys{i} =  [d.contour(i,3);d.contour(i,4)];
end
toc
zs = repmat({[1;1]},size(ys,1),size(ys,2));

ph = cellfun(@line, xs, ys, zs, colors1, colors2, tags1, tags2, 'UniformOutput',false);

ph2=[];

% if strcmp(UCIT_DC_getInfoFromPopup('TransectsDatatype'),'Lidar Data US')
%
%     %% get info to plot shoreposition
%     % get lat info
%     shoreLat = {d(id).shoreEast}';
%     id1 = cellfun(@ismember, shoreLat,repmat({-999.9900}, size(shoreLat)),'UniformOutput',false);
%     shoreLat(vertcat(id1{:})) = {nan};
%
%     % get lon info and replace nans
%     shoreLon = {d(id).shoreNorth}';
%     id2 = cellfun(@ismember, shoreLon,repmat({-999.9900}, size(shoreLon)),'UniformOutput',false);
%     shoreLon(vertcat(id2{:})) = {nan};
%
%     % get zs info to make sure the plotted info lies above the land boundary
%     S       = repmat({30},size(shoreLat));
%
%     markerst1  = repmat({'marker'},size(shoreLat));
%     markerst2  = repmat({'o'},size(shoreLat));
%     markerfc1  = repmat({'markerfacecolor'},size(shoreLat));
%     markerfc2  = repmat({'g'},size(shoreLat));
%     markerec1  = repmat({'markeredgecolor'},size(shoreLat));
%     markerec2  = repmat({'g'},size(shoreLat));
%     % markersz1  = repmat({'markersize'},size(shoreLat));
%     % markersz2  = repmat({[10]},size(shoreLat));
%     try %#ok<TRYNC>
%         ph2 = cellfun(@scatter, shoreLat, shoreLon, S, markerst1, markerst2, markerfc1, markerfc2, markerec1, markerec2, 'UniformOutput',false);
%     end
% else
%     ph2=[];
% end


