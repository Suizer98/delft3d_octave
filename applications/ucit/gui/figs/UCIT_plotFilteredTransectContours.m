function UCIT_plotFilteredTransectContours(d, axisNew) %#ok<INUSD>
%UCIT_PLOTFILTEREDTRANSECTCONTOURS  plots transect outlines in overview
%figure of UCIT gui (filtered)
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
%   Example
%   
%
%   See also UCIT_plotTransectOutlines

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

if nargin == 2 % remake figure using zoom
    fh = findobj('tag','mapWindow');
    figure(fh);
else % make figure new
    if ~isempty(findobj('tag','mapWindow'))
          close(findobj('tag','mapWindow'));
    end

    fh=figure('tag','mapWindow');clf;
    ah=axes;
    [fh] = UCIT_prepareFigureN(1, fh, 'LL', ah, @UCIT_plotFilteredTransectContours, {get(findobj('tag','UCIT_mainWin'),'Userdata'), axis(ah)}, @UCIT_plotTransectContours, {get(findobj('tag','UCIT_mainWin'),'Userdata'), axis(ah)});
    set(fh,'name','UCIT - Transect overview');
    set(gca, 'fontsize',8);

end

handles = guidata(fh);

% compare axis with axis new
if ~isfield(handles,'axisOld'); %if the transect contours are plotted for the first time
    axis equal;
    disp('plotting landboundary...');
    UCIT_plotLandboundary(d.ldb);
    set(fh,'visible','off');
    set(fh,'userdata',axis);    
    hold on;
    box on
    
    % Add additional lines
    if isfield(d,'extra')
        if ~strcmp(d.extra,'')
        X2	=  nc_varget(d.extra,'x');
        Y2	=  nc_varget(d.extra,'y');
        plot(X2,Y2,'r','linewidth',1.5);hold on;
    end
end

    id = zeros(length(d.contour),1);
    
    initial_stepsize = 100;
    
    if strcmp(d.datatypeinfo{1}, 'Jarkus Data')
        initial_stepsize = 1;
    end
    
    id(1:initial_stepsize:end) = 1; % apply filtering for the initial plot
    
    [handles.ph,handles.ph2] = drawData(fh, d, id);

    handles.axisOld = axis;
    handles.XMaxRange = [handles.axisOld(1) handles.axisOld(2)];
    handles.YMaxRange = [handles.axisOld(3) handles.axisOld(4)];

elseif  sum(handles.axisOld ~= axis) ~= 0  % elseif axis and axisNew are NOT the same
    axisCur = axis;
    polygon = [axisCur(1) axisCur(3); axisCur(2) axisCur(3); axisCur(2) axisCur(4); axisCur(1) axisCur(4); axisCur(1) axisCur(3)];

    test = d.contour;
    id1 = inpolygon(test(:,1),test(:,3),polygon(:,1),polygon(:,2));
    id2 = inpolygon(test(:,2),test(:,4),polygon(:,1),polygon(:,2));
    id = (id1|id2);

    [ph, ph2] = drawData(fh, d, id, handles.ph, handles.ph2);

    handles.ph = ph;
    handles.ph2 = ph2;
    handles.axisOld = axis;

end

guidata(fh,handles);

%%
function [ph, ph2] = drawData(fh, d, id, ph, ph2) %#ok<INUSL>

if nargin == 5
    try %#ok<TRYNC>
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
end

stepsize = 1;

title ({''}); % ['Thinning factor: ' num2str(stepsize)]
drawnow
[ph, ph2] = displayFilteredTransects(d, id, stepsize);

%%
function [ph, ph2] = displayFilteredTransects(d, id, stepsize)

%% get info needed to construct a proper tag
soundingID   = repmat({datestr(d.year(end)+ datenum(1970,1,1))},size(d.area));
separator    = repmat({'_'}    ,size(d.area));
colors1      = repmat({'color'},size(d.area));
colors2      = repmat({'r'}    ,size(d.area));
tags1        = repmat({'tag'}  ,size(d.area));
tags2        = cellfun(@horzcat, d.datatypeinfo,separator,d.area,separator,d.transectID,separator,soundingID,'UniformOutput',false);

[xs, ys, zs] = deal(repmat({[1;1]}, size(d.area)));

for i = find(id)'
    xs{i} =  [d.contour(i,1);d.contour(i,2)];
    ys{i} =  [d.contour(i,3);d.contour(i,4)];
end


zs = repmat({[1;1]},size(ys,1),size(ys,2));
tic
disp('drawing transects...');
ph = cellfun(@line, {xs{find(id)}}, {ys{find(id)}}, {zs{find(id)}}, {colors1{find(id)}}, {colors2{find(id)}}, {tags1{find(id)}}, {tags2{find(id)}}, 'UniformOutput',false);
toc
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
