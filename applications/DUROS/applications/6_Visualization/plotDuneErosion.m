function plotDuneErosion(Result, varargin)
%PLOTDUNEEROSION    routine to plot dune erosion results
%
% This routine plots the results of a dune erosion calculation in a figure.
% The result structure is also stored in the axes containing the plotted results.
%
% Syntax:       plotduneerosion(result, nr, PropertyName, PropertyValue)
%
% Input:
%               result    = structure with dune erosion results
%               nr        = figure number or handle (optional), or axes
%                           handle.
%
%               Property-value pairs:
%               xoffset   = a double denoting the length that is added to
%                           all x-coordinates in the plot.
%               zoffset   = a double denoting the height that is added to
%                           all z-coordinates in the plot.
%               xdir      = {reverse} | normal. Positive direction of the
%                            x-axis. This must be reverse in case of a
%                            positive direction to the left, or normal
%                            plotting the matlab default axes direction.
%
% Output:       Eventual output is plotted in figure(nr)
%
%   See also getDuneErosion_DUROS
%
% --------------------------------------------------------------------------
% Copyright (c) Deltares 2004-2008 FOR INTERNAL USE ONLY
% Version:      Version 1.2, june 2009 (Version 1.0, January 2007)
% By:           <Pieter van Geer and C.(Kees) den Heijer (email: Kees.denHeijer@deltares.nl)>
% --------------------------------------------------------------------------

% $Id: plotDuneErosion.m 2484 2010-04-26 07:42:20Z heijer $
% $Date: 2010-04-26 15:42:20 +0800 (Mon, 26 Apr 2010) $
% $Author: heijer $
% $Revision: 2484 $
% $Keywords: plot, dune erosion$

%%

OPT = struct(...
    'title', '',...
    'xdir','reverse',...
    'xoffset',0,...
    'zoffset',0,...
    'xlabel', 'cross shore distance to RSP [m]',...
    'ylabel', 'height to NAP [m]',...
    'hordatum', 'RSP',...
    'vertdatum', 'NAP',...
    'legenditems', {{'Hs' 'Tp' 'D50' 'Er'}});

if nargin>1
    if ishandle(varargin{1})
        nr = varargin{1};
        varargin(1) = [];
    end
    getdefaults('nr', gcf, 0);
    if ishandle(nr)
        fig = nr;
    else
        fig = figure(nr);
    end

    OPT = setproperty(OPT, varargin{:});
    
    OPT.xlabel = strrep(OPT.xlabel, 'RSP', OPT.hordatum);
    OPT.ylabel = strrep(OPT.ylabel, 'NAP', OPT.vertdatum);
    if all(~strcmp(OPT.xdir,{'normal','reverse'}))
        error('PlotDuneErosion:WrongProperty','Parameter xdir can only be "normal" or "reverse"');
    end
    if ~isnumeric(OPT.xoffset)
        error('PlotDuneErosion:WrongProperty','Parameter xoffset must be numeric');
    end
else
    fig = gcf;
end

if strcmp(get(fig,'Type'),'axes')
    parent = fig;
    % fig is not the handle to the figure, but we don't need it anyway...
elseif strcmp(get(fig,'Type'),'figure')
    % Why don't we just take gca???
    children = get(fig, 'children');
    isAxes = strcmp(get(children, 'type'), 'axes') & ~strcmp(get(children, 'tag'), 'legend');
    if sum(isAxes) == 1
        parent = children(isAxes);
    else
        parent = axes(...
            'Parent', fig);
    end
else
    error('plotDuneErosion:WrongHandle','The handle specified is not of type axis or figure.');
end
set(parent,...
    'Xdir', OPT.xdir,...
    'Box', 'on',...
    'color', 'none',...
    'NextPlot', 'add')

xlabel(OPT.xlabel)
ylabel(OPT.ylabel),...
%     'Rotation', 270,...
%     'VerticalAlignment', 'top')
if ~isempty(OPT.title)
    title(OPT.title)
end

lastFilledField = [];
for i = fliplr(1 : length(Result))
    fieldIsempty = isempty(Result(i).xActive);
    if ~fieldIsempty
        lastFilledField = i;
        break
    end
end

hsc = [];
[xInitial, zInitial] = deal([Result(1).xLand; Result(1).xActive; Result(1).xSea]+OPT.xoffset, [Result(1).zLand; Result(1).zActive; Result(1).zSea]+OPT.zoffset);

if ~issorted(xInitial)
    % relevant if poslndwrd == 1
    [xInitial IX] = sort(xInitial);
    zInitial = zInitial(IX);
end

hInitialProfile = plot(xInitial, zInitial,...
    'Color','k',...
    'LineStyle','-',...
    'Parent',parent,...
    'LineWidth',1,...
    'DisplayName','Initial profile');

initXLimits = [min(xInitial) max(xInitial)];
initZLimits = get(parent, 'YLim');
Tmp = guihandles(fig);

if ~isempty(get(Tmp.FigureToolBar, 'children'))
    % delete existing toolbar items
    delete(get(Tmp.FigureToolBar, 'children'))
end
%if exist('stretchaxes.bmp','file')
    pushIm = imread('stretchaxes.bmp');
%else
%    pushim = repmat(0,[315,315,3]);
%end
uipushtool('CData',pushIm,...
    'ClickedCallback',{@resetaxis, parent, initXLimits, initZLimits},...
    'Parent',Tmp.FigureToolBar,...
    'Separator','on',...
    'Tag','Set XS Limits',...
    'TooltipString','Reset axis');

color = {[255 222 111]/255, [150 116 0]/255, [0 0.8 0], [1 0.6 1], [0 0.8 0]};
if length(Result) > length(color)
    color = [color(1:2) {.9*color{1}} color(3:end)];
end
hp = NaN(size(Result));
txt = cell(size(Result));
tpCorrected = false;
for i = 1 : lastFilledField
    if ~isempty(Result(i).z2Active)
        if isfield(Result(i).info, 'ID')
            txt{i} = Result(i).info.ID; % not applicable in case of debugging when result(i).info.ID doesn't exist
        end
        volumePatch = [Result(i).xActive'+OPT.xoffset fliplr(Result(i).xActive')+OPT.xoffset; Result(i).z2Active'+OPT.zoffset fliplr(Result(i).zActive')+OPT.zoffset]';
        hp(i) = patch(volumePatch(:,1), volumePatch(:,2), ones(size(volumePatch(:,2)))*-(lastFilledField-i),color{i},...
            'EdgeColor',[1 1 1]*0.5,...
            'Parent',parent);
        if max(diff(volumePatch)) == 0
            if i == 1
                % displaying the empty patch of the DUROS profile in the legend
                % makes no sense
                set(hp(i), 'HandleVisibility','off')
            else
                % only the remark "no erosion" is required, the color of
                % the patch isn't
                set(hp(i), 'EdgeColor','none', 'FaceColor', 'none');
            end
        end
        if isempty(txt{i})
            txt{i} = 'UnKnown';
        end
        try
            % DisplayNames for patches are only possible for matlab
            % version 8 and higher
            set(hp(i), 'DisplayName',txt{i});
        catch %#ok<CTCH>
            % alternatively put the text in the Tag
            set(hp(i), 'Tag', txt{i});
        end
        %% Displayname
        if i > 1
            %{
            hsc(end+1) = scatter(result(i).xActive(1),result(i).z2Active(1),...
                'Marker','o',...
                'HandleVisibility','off',...
                'MarkerFaceColor','k',...
                'MarkerEdgeColor','k',...
                'SizeData',4,...
                'Parent',parent); %#ok<AGROW>
            id = find(result(i).z2Active==min(result(i).z2Active), 1 );
            hsc(end+1) = scatter(result(i).xActive(id),result(i).z2Active(id),...
                'Marker','o',...
                'HandleVisibility','off',...
                'MarkerFaceColor','k',...
                'MarkerEdgeColor','k',...
                'SizeData',4,...
                'Parent',parent); %#ok<AGROW>
            %}
        else
            hErosionProfile = plot(Result(i).xActive+OPT.xoffset, Result(i).z2Active+OPT.zoffset,...
                'Color','r',...
                'LineStyle','-',...
                'Parent',parent,...
                'LineWidth',2,...
                'DisplayName','Erosion profile');
            if isscalar(Result(i).xActive)
                set(hErosionProfile,...
                    'HandleVisibility','off');
            end
        end
    end
    % TODO('Change the i's / 1's for DUROSresultid in some cases');
    if ~isempty(Result(i).info.messages) && any([Result(i).info.messages{:,1}]==-2)
        oldTpText = Result(i).info.messages{[Result(i).info.messages{:,1}]==-2,2};
        spaces = strfind(oldTpText,' ');
        oldTp = str2double(oldTpText(spaces(end-1):spaces(end)));
        tpCorrected = true;
    end
    if ~isempty(Result(i).info.messages) && any([Result(i).info.messages{:,1}]==-99)
        text(0.5, 0.45,'Iteration boundaries are non-consistent!','Units','normalized','Rotation',0,'FontSize',16,'color','r','HorizontalAlignment','center');
    end
    if ~isempty(Result(1).info.messages) && any([Result(1).info.messages{:,1}]==-8)
        text(0.5, 0.45,{'The initial profile is not steep enough','to yield a solution under these conditions'},'Units','normalized','Rotation',0,'FontSize',16,'color','r','HorizontalAlignment','center');
    end
    if ~isempty(Result(i).info.messages) && any([Result(i).info.messages{:,1}]==-7)
        text(0.5, 0.45,'No solution found within boundaries!','Units','normalized','Rotation',35,'FontSize',20,'color','r','HorizontalAlignment','center');
    end
    if ~isempty(Result(1).info.messages) && any([Result(1).info.messages{:,1}]==-6)
        text(0.5, 0.1,'Solution is influenced by a channel slope!','Units','normalized','Rotation',0,'FontSize',16,'color','r','HorizontalAlignment','center');
    end
    if ~isempty(Result(1).info.messages) && any([Result(1).info.messages{:,1}]==-5)
        text(0.5, 0.45,'Corrected for landward transport above the water line.','Units','normalized','Rotation',35,'FontSize',16,'color','r','HorizontalAlignment','center');
    end
    if ~isempty(Result(i).info.messages) && any([Result(i).info.messages{:,1}]==45)
        text(0.5, 0.1,'Additional erosion restricted within dune valley.','Units','normalized','Rotation',0,'FontSize',16,'color','r','HorizontalAlignment','center');
    end
    if ~isempty(Result(i).info.messages) && any([Result(i).info.messages{:,1}]==42)
        text(0.5, 0.1,'Additional retreat limit reached.','Units','normalized','Rotation',0,'FontSize',16,'color','r','HorizontalAlignment','center');
    end
    if ~isempty(Result(i).info.messages) && any([Result(i).info.messages{:,1}]==47)
        id = [Result(i).info.messages{:,1}]==47;
        text(0.5, 0.1,Result(i).info.messages{id,2},'Units','normalized','Rotation',0,'FontSize',12,'color','r','HorizontalAlignment','center');
    end
end

xLimits = [min(Result(i).xActive+OPT.xoffset) max(Result(1).xActive+OPT.xoffset)];
%     xlimits = [min(x) max(result(1).xActive)];
if numel(Result(1).xActive)<2
    if diff(xLimits)==0 %No erosion (active profile has no length) and no additional erosion
        xLimits = [min(Result(1).xLand+OPT.xoffset) max(Result(1).xSea+OPT.xoffset)];
        if length(xLimits)==1
            xLimits = ones(1,2)*xLimits;
        end
        zLimits = [min(Result(1).zSea)+OPT.zoffset max(Result(1).zLand)+OPT.zoffset];
        if length(zLimits)==1
            zLimits = ones(1,2)*zLimits;
        end
    else % No erosion, but additional erosion/ boundary profile was calculated
        xLimits = [min(xLimits)-150 max(xLimits)+150];
        zLimits = [min(zInitial(xInitial>xLimits(1) & xInitial<xLimits(2))) max(zInitial(xInitial>xLimits(1) & xInitial<xLimits(2)))];
        zLimits = [zLimits(1)-.05*diff(zLimits) zLimits(2)+.05*diff(zLimits)];
    end
    text(xLimits(2)-0.8*diff(xLimits),zLimits(2)-0.8*diff(zLimits),'No erosion');
else
    xLimits = [xLimits(1)-.05*diff(xLimits) xLimits(2)+.05*diff(xLimits)];
    zLimits = [min(zInitial(xInitial>xLimits(1) & xInitial<xLimits(2))) max(zInitial(xInitial>xLimits(1) & xInitial<xLimits(2)))];
    zLimits = [zLimits(1)-.05*diff(zLimits) zLimits(2)+.05*diff(zLimits)];
end
try %#ok<TRYNC>
    axis([xLimits zLimits]);
    uistack(hInitialProfile,'top');
    uistack(hErosionProfile,'top');
    uistack(hsc,'top');
end

[waterLevel,erosionVolume, aVolume, xpLocation, tVolume] = deal(nan);

for i = 1 : lastFilledField
    if ~isempty(Result(i).info.input) && isfield(Result(i).info.input,'WL_t')
        waterLevel = Result(i).info.input.WL_t+OPT.zoffset;
    end
    if ~isempty(cat(1,Result(i).info.ID))
        if ismember({Result(i).info.ID},'DUROS-plus') || ismember({Result(i).info.ID},'DUROS')
            if ~isempty(Result(i).Volumes.Erosion)
                erosionVolume = -Result(i).Volumes.Erosion;
            else
                erosionVolume = nan;
            end
        elseif ismember({Result(i).info.ID},'DUROS-plus Erosion above SSL') || ismember({Result(i).info.ID},'DUROS Erosion above SSL')
            aVolume = Result(i).VTVinfo.AVolume;
        elseif ismember({Result(i).info.ID},'Additional Erosion')
            xpPoint = Result(i).VTVinfo.Xp+OPT.xoffset;
            zpPoint = Result(i).VTVinfo.Zp+OPT.zoffset;
            xrPoint = Result(i).VTVinfo.Xr+OPT.xoffset;
            zrPoint = Result(i).VTVinfo.Zr+OPT.zoffset;
            if isempty(xpPoint) || isempty(xrPoint)
                continue;
            end

            hsc(end+1) = plot(xpPoint,zpPoint,...
                'Marker','o',...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor', 'b',...
                'MarkerSize', 5,...
                'HandleVisibility', 'on',...
                'LineStyle','none',...
                'DisplayName',['P: ',num2str(xpPoint,'%8.2f'),' m w.r.t. ' OPT.hordatum],...
                'Parent', parent); %#ok<AGROW>
            hsc(end+1) = plot(xrPoint,zrPoint,...
                'Marker','o',...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor', 'r',...
                'MarkerSize', 5,...
                'HandleVisibility', 'on',...
                'LineStyle','none',...
                'DisplayName',['R: ',num2str(xrPoint,'%8.2f'),' m w.r.t. ' OPT.hordatum],...
                'Parent', parent); %#ok<AGROW>
            tVolume = Result(i).VTVinfo.TVolume;
            if isempty(tVolume)
                tVolume = nan;
            end
        end
    end
end

hpTemp = hp(~isnan(hp));
try
    if length(hp)==1
        aVolumeId = ~isempty(strfind(get(hpTemp, 'DisplayName'), 'Erosion above SSL'));
        tVolumeId = ~isempty(strfind(get(hpTemp, 'DisplayName'), 'Additional Erosion'));
    else
        aVolumeId = ~cellfun(@isempty, strfind(get(hpTemp, 'DisplayName'), 'Erosion above SSL'));
        tVolumeId = ~cellfun(@isempty, strfind(get(hpTemp, 'DisplayName'), 'Additional Erosion'));
    end
    set(hptemp(aVolumeId), 'DisplayName', [get(hptemp(aVolumeId), 'DisplayName') ' (' num2str(aVolume,'%8.2f'),' m^3/m^1)'])
    set(hptemp(tVolumeId), 'DisplayName', [get(hptemp(tVolumeId), 'DisplayName') ' (' num2str(tVolume,'%8.2f'),' m^3/m^1)'])
catch %#ok<CTCH>
    if length(hp)==1
        aVolumeId = ~isempty(strfind(get(hpTemp, 'Tag'), 'Erosion above SSL'));
        tVolumeId = ~isempty(strfind(get(hpTemp, 'Tag'), 'Additional Erosion'));
    else
        aVolumeId = ~cellfun(@isempty, strfind(get(hpTemp, 'Tag'), 'Erosion above SSL'));
        tVolumeId = ~cellfun(@isempty, strfind(get(hpTemp, 'Tag'), 'Additional Erosion'));
    end
    set(hpTemp(aVolumeId), 'Tag', [get(hpTemp(aVolumeId), 'Tag') ' (' num2str(aVolume,'%8.2f'),' m^3/m^1)'])
    set(hpTemp(tVolumeId), 'Tag', [get(hpTemp(tVolumeId), 'Tag') ' (' num2str(tVolume,'%8.2f'),' m^3/m^1)'])
end

results2Plot = {};
if any(ismember(OPT.legenditems, 'Er'))
    results2Plot = {
        'Er: ',num2str(erosionVolume,'%8.2f'),' m^3/m^1'};
end
% remove lines with nans
results2Plot(isnan(erosionVolume),:) = [];

try
    hwl = plot([min(xInitial) max(xInitial)], repmat(waterLevel,1,2),'--b');
    try
        set(hwl,'Tag',['WL: ', num2str(waterLevel, '%8.2f'), ' m w.r.t. ' OPT.vertdatum],...
            'DisplayName',['WL: ', num2str(waterLevel, '%8.2f'), ' m w.r.t. ' OPT.vertdatum],...
            'HandleVisibility','on');
    catch %#ok<CTCH>
        set(hwl,'Tag',['WL: ', num2str(waterLevel, '%8.2f'), ' m w.r.t. ' OPT.vertdatum],...
            'HandleVisibility','on');
    end
    input2Plot = {...
        'Hs: ', num2str(Result(1).info.input.Hsig_t, '%8.2f'), ' m'; ...
        'Tp: ', num2str(Result(1).info.input.Tp_t, '%8.2f'), ' s'; ...
        'D50: ', num2str(Result(1).info.input.D50*1e6, '%8.2f'), ' \mum'};
catch %#ok<CTCH>
    input2Plot = {};
end
displayResultsOnFigure(parent,[input2Plot; results2Plot])
if strcmp(OPT.xdir,'normal')
    leg = legend(parent);
    set(leg,'Location','NorthEast');
    legendxdir(leg,'xdir','reverse');
end
if tpCorrected
    leg = legend(parent);
    ch = findobj(leg,'Type','text');
    str = get(ch,'String');
    tpId = strncmp(str,'Tp:',3);
    if sum(tpId==1)==1
        set(ch(tpId),...
            'String',cat(2,get(ch(tpId),'String'),[' (target: ' num2str(oldTp, '%8.2f') ' s)']),...
            'Color','r');
    end
end
%% store results in userdata.
% In this way storing one figure stores the
% complete result. No need to seperately store the .mat file anymore
set(parent,'UserData',Result);

function resetaxis(varargin)

set(varargin{3}, 'XLim', varargin{4}, 'YLim', varargin{5})