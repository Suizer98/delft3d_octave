function h = plot_scatterhist(x,y,varargin)
%PLOT_SCATTERHIST 2D scatter plot with marginal histograms.
%   PLOT_SCATTERHIST(X,Y) creates a 2D scatterplot of the data in the vectors X
%   and Y, and puts a univariate histogram on the horizontal and vertical
%   axes of the plot.  X and Y must be the same length.
%
%   PLOT_SCATTERHIST(...,'PARAM1',VAL1,'PARAM2',VAL2,...) specifies additional
%   parameters and their values to control how the plot is made.  Valid
%   parameters are the following:
%
%       Parameter    Value
%
%        'xBins'     A scalar or a vector specifying the number of bins or 
%                    the vector bins for the X. The default is 10.
%
%        'yBins'     A scalar or a vector specifying the number of bins or 
%                    the vector bins for the X. The default is 10.
%
%        'cBins'     A scalar or a vector specifying the number of
%                    percentiles or a vector of bins for the color. 
%                    The default is 10.
%
%        'Location'  A string controlling the location of the marginal
%                    histograms within the figure.  'SouthWest' (the default)
%                    plots the histograms below and to the left of the
%                    scatterplot, 'SouthEast' plots them below and to the
%                    right, 'NorthEast' above and to the right, and 'NorthWest'
%                    above and to the left.
%
%        'Direction' A string controlling the direction of the marginal
%                    histograms in the figure.  'in' (the default) plots the
%                    histograms with bars directed in towards the scatterplot,
%                    'out' plots the histograms with bars directed out away
%                    from the scatterplot.
%
%        'plot'     A string controlling the type of plot
%                   'histscatter' scatter points plot and histograms
%                   'histdensity' scatter density plot and histograms
%                   'scatter' scatter points
%                   'density' scatter density
%                   The default is histdensity.
%
%   Any NaN values in either X or Y are treated as missing data, and are
%   removed from both X and Y.  Therefore the plots reflect points for
%   which neither X nor Y has a missing value.
%
%   Use the data cursor to read precise values and observation numbers 
%   from the plot.
%
%   H = PLOT_SCATTERHIST(...) returns a vector of three axes handles for the
%   scatterplot, the histogram along the horizontal axis, and the histogram
%   along the vertical axis, respectively.
%
%   Example:
%      Independent normal and lognormal random samples
%         x = randn(1000,1);
%         y = exp(.5*randn(1000,1));
%         plot_scatterhist(x,y)
%      xBins and yBins are equal to 50
%         plot_scatterhist(x,y,50)
%
%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2012-Aug-13 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------


%narginchk(2, Inf);

if ~isvector(x) || ~isnumeric(x) || ~isvector(y) || ~isnumeric(y)
    error(message('plot_scatterhist:BadXY'));
end
if numel(x)~=numel(y)
    error(message('plot_scatterhist:BadXY'));
end
x = x(:);
y = y(:);
obsinds = 1:numel(x);
t = isnan(x) | isnan(y);
if any(t)
    x(t) = [];
    y(t) = [];
    obsinds(t) = [];
end

% Default values
location = 'sw';  
direction = 'in'; 
xbins = 10;
ybins = 10;
plotType = 'histdensity';
colorbinOn = 0;
perc = 0;

if nargin >2 && isnumeric(varargin{1})
   if ~isempty(varargin{1})
       xbins = varargin{1};
       ybins = varargin{1};
   end
end
if nargin >3 && isnumeric(varargin{2})
   if ~isempty(varargin{2})
       xbins = varargin{2};
   end
end
    
if nargin>2
    for ichar = 1:nargin-2        
        if ischar(varargin{ichar})
            loc = {'SouthWest' 'SouthEast' 'NorthEast' 'NorthWest'};
            dir = {'in' 'out'};
            plots = {'histscatter' 'histdensity' 'scatter' 'density'};
            colorbin = {'cBins'};

            iloc  = strcmpi(loc,varargin(ichar));  
            idir  = strcmpi(dir,varargin(ichar));
            iplot = strcmpi(plots,varargin(ichar));
            ibin  = strcmpi(colorbin,varargin(ichar));
            iperc = strcmpi('perc',varargin(ichar));

            if any(iloc)
               location = loc{iloc};
            end
            if any(idir)
               direction = dir{idir};
            end
            if any(iplot)
               plotType = plots{iplot};
            end
            if any(ibin)
               cbins = varargin{ichar+1};
               colorbinOn = 1;
            end
            if any(iperc)
               perc = 1;
            end
        end
    end
end

xctrs = xbins;
yctrs = ybins;
e = x-y;
se = std(e);

% Create the histogram information
[nx,cx] = hist(x,xctrs);
if length(cx)>1
    dx = diff(cx(1:2));
else
    dx = 1;
end
xlim = [cx(1)-dx cx(end)+dx];

[ny,cy] = hist(y,yctrs);
if length(cy)>1
    dy = diff(cy(1:2));
else
    dy = 1;
end
ylim = [cy(1)-dy cy(end)+dy];

% Find density points
if any(strcmpi(plotType,{'histdensity' 'density'}))
    c = nan(length(cx)-1,length(cy)-1);
    ix = nan(length(cx)-1,length(cy)-1);
    iy = nan(length(cx)-1,length(cy)-1);

    k = 0;
    for i = 1:length(cx)-1
        for j = 1:length(cy)-1
            k = k+1;
            ix(i,j) = mean([cx(i) cx(i+1)]);    
            iy(i,j) = mean([cy(j) cy(j+1)]);
            lx = find(x>cx(i) & x<=cx(i+1));
            n = sum(y(lx)>cy(j) & y(lx)<=cy(j+1));
            if n>1
               c(i,j) = n;
            else
                c(i,j) = nan;
            end

        end
    end
    
% If normalized
if perc
  n = ~isnan(x);
  n = sum(n(:));
  c = (c./n)*100;  
end

if colorbinOn
   if length(cbins)==1
      cmin = min(c(:));
      cmax = max(c(:));
      cbins = percentile(c(~isnan(c(:))),[0:100/cbins:100]);
   end
    interval = cbins;
    z = nan(size(c));
    clear clabel
    clabel(1:length(interval)) = {''};
   cnumber = 1:0.5:length(interval)-.5;
    for ii = 1:length(interval)-1
       index = (c>interval(ii)) & (c<=interval(ii+1));
       clabel{(ii*2)}= [num2str(round(interval(ii))) '-' num2str(round(interval(ii+1)))];
       z(index) = ii-1;         
    end
   c = z;
end

end

clf
set(gcf,'Color','w');

if any(strcmpi(plotType,{'histdensity' 'histscatter'}))

% Set up positions for the plots
switch lower(direction)
case 'in'
    inoutSign = 1;
case 'out'
    inoutSign = -1;
otherwise
    error(message('plot_scatterhist:BadDirection'));        
end
switch lower(location)
case {'ne' 'northeast'}
    scatterLoc = 3;
    scatterPosn = [.1 .1 .55 .55];
    scatterXAxisLoc = 'top'; scatterYAxisLoc = 'right';
    histXLoc = 1; histYLoc = 4;
    histXSign = -inoutSign; histYSign = -inoutSign;
case {'se' 'southeast'}
    scatterLoc = 1;
    scatterPosn = [.1 .35 .55 .55];
    scatterXAxisLoc = 'bottom'; scatterYAxisLoc = 'right';
    histXLoc = 3; histYLoc = 2;
    histXSign = inoutSign; histYSign = -inoutSign;
case {'sw' 'southwest'}
    scatterLoc = 2;
    scatterPosn = [.35 .35 .55 .55];
    scatterXAxisLoc = 'bottom'; scatterYAxisLoc = 'left';
    histXLoc = 4; histYLoc = 1;
    histXSign = inoutSign; histYSign = inoutSign;
case {'nw' 'northwest'}
    scatterLoc = 4;
    scatterPosn = [.35 .1 .55 .55];
    scatterXAxisLoc = 'top'; scatterYAxisLoc = 'left';
    histXLoc = 2; histYLoc = 3;
    histXSign = -inoutSign; histYSign = inoutSign;
otherwise
    error(message('plot_scatterhist:BadLocation'));        
end

% Put up the histograms in preliminary positions.
hHistY = subplot(2,2,histYLoc);
barh(cy,histYSign*ny,1);
xmax = max(ny);
if xmax == 0, xmax = 1; end % prevent xlim from being [0 0]
axis([sort(histYSign*[xmax, 0]), ylim]);
axis('off');

hHistX = subplot(2,2,histXLoc);
bar(cx,histXSign*nx,1);
ymax = max(nx);
if ymax == 0, ymax = 1; end % prevent ylim from being [0 0]
axis([xlim, sort(histXSign*[ymax, 0])]);
axis('off');

% Put the scatterplot up last to put it first on the child list
hScatter = subplot(2,2,scatterLoc);
if any(strcmpi(plotType,'histdensity'))
   hScatterline = scatter(ix(:),iy(:),5,c(:),'filled');
else
   hScatterline = plot(x,y,'o');
end
hold on
plim = [min([xlim ylim]) max([xlim ylim])];
plot(plim, plim,':k')
axis([xlim ylim]);
axis square
box on

% Create invisible text objects for later use
txt1 = text(0,0,'42','Visible','off','HandleVisibility','off');
txt2 = text(1,1,'42','Visible','off','HandleVisibility','off');

% Make scatter plot bigger, histograms smaller
set(hScatter,'Position',scatterPosn, 'XAxisLocation',scatterXAxisLoc, ...
             'YAxisLocation',scatterYAxisLoc, 'tag','scatter');
set(hHistX,'tag','xhist');
set(hHistY,'tag','yhist');

scatterhistPositionCallback();


% Attach custom datatips
if ~isempty(hScatterline) % datatips only if there are data
    hB = hggetbehavior(hScatterline,'datacursor');
    set(hB,'UpdateFcn',@scatterhistDatatipCallback);
    setappdata(hScatterline,'obsinds',obsinds);
end

% Add listeners to resize or relimit histograms when the scatterplot changes
addlistener(hScatter,{'Position' 'OuterPosition'}, 'PostSet',@scatterhistPositionCallback);
addlistener(hScatter,{'XLim' 'YLim'},'PostSet',@scatterhistXYLimCallback);

% Leave scatter plot as current axes
set(get(hScatter,'parent'),'CurrentAxes',hScatter);
end

if any(strcmpi(plotType,{'density' 'scatter'}))
   hScatter = gca;
   if any(strcmpi(plotType,'density'))
      scatter(ix(:),iy(:),5,c(:),'filled');
   else
      plot(x,y,'o');
   end
   hold on
   plim = [min([xlim ylim]) max([xlim ylim])];
   plot(plim, plim,':k')
   % If 95 percentge (2 sigmas)
   plot(plim+(2*se), plim,':k','color',[0.8 0.8 0.8])
   plot(plim-(2*se), plim,':k','color',[0.8 0.8 0.8])

   axis([xlim ylim]);
   axis square
   box on
end
if any(strcmpi(plotType,{'histdensity' 'density'})) && colorbinOn
    colormap(jet(length(interval)-1));
    clim([1 length(interval)]);
    h = colorbar('YTick',cnumber,'YTickLabel',clabel);
    axes(h);
    title('No. Obs.','FontSize',10,'fontweight','bold');
   
end

% Leave scatter plot as current axes
set(get(hScatter,'parent'),'CurrentAxes',hScatter);

if nargout>0
    h = [hScatter hHistX hHistY];
end



% -----------------------------
function scatterhistPositionCallback(~,~)
posn = getrealposition(hScatter,txt1,txt2);
if feature('HGUsingMATLABClasses')
    % drawnow ensures that OuterPosition is updated
    drawnow('expose');
end
oposn = get(hScatter,'OuterPosition');

switch lower(location)
case {'sw' 'southwest'}
    % vertically: margin, histogram, margin/4, scatterplot, margin
    vmargin = min(max(1 - oposn(2) - oposn(4), 0), oposn(2));
    posnHistX = [posn(1) vmargin posn(3) oposn(2)-1.25*vmargin];
    % horizontally: margin, histogram, margin/4, scatterplot, margin
    hmargin = min(max(1 - oposn(1) - oposn(3), 0), oposn(1));
    posnHistY = [hmargin posn(2) oposn(1)-1.25*hmargin posn(4)];
case {'ne' 'northeast'}
    % vertically: margin, scatterplot, margin/4, histogram, margin
    vmargin = max(oposn(2), 0);
    posnHistX = [posn(1) oposn(2)+oposn(4)+.25*vmargin posn(3) 1-oposn(2)-oposn(4)-1.25*vmargin];
    % horizontally: margin, scatterplot, margin/4, histogram, margin
    hmargin = max(oposn(1), 0);
    posnHistY = [oposn(1)+oposn(3)+.25*hmargin posn(2) 1-oposn(1)-oposn(3)-1.25*hmargin posn(4)];
case {'se' 'southeast'}
    % vertically: margin, histogram, margin/4, scatterplot, margin
    vmargin = max(1 - oposn(2) - oposn(4), 0);
    posnHistX = [posn(1) vmargin posn(3) oposn(2)-1.25*vmargin];
    % horizontally: margin, scatterplot, margin/4, histogram, margin
    hmargin = max(oposn(1), 0);
    posnHistY = [oposn(1)+oposn(3)+.25*hmargin posn(2) 1-oposn(1)-oposn(3)-1.25*hmargin posn(4)];
case {'nw' 'northwest'}
    % vertically: margin, scatterplot, margin/4, histogram, margin
    vmargin = max(oposn(2), 0);
    posnHistX = [posn(1) oposn(2)+oposn(4)+.25*vmargin posn(3) 1-oposn(2)-oposn(4)-1.25*vmargin];
    % horizontally: margin, histogram, margin/4, scatterplot, margin
    hmargin = max(1 - oposn(1) - oposn(3), 0);
    posnHistY = [hmargin posn(2) oposn(1)-1.25*hmargin posn(4)];
end
posnHistX = max(posnHistX,[0 0 .05 .05]);
posnHistY = max(posnHistY,[0 0 .05 .05]);

set(hHistX,'Position',posnHistX);
set(hHistY,'Position',posnHistY);

scatterhistXYLimCallback();
end

% -----------------------------
function scatterhistXYLimCallback(~,~)
set(hHistX,'Xlim',get(hScatter,'XLim'));
set(hHistY,'Ylim',get(hScatter,'YLim'));
end

% -----------------------------
function datatipTxt = scatterhistDatatipCallback(~,evt)
target = get(evt,'Target');
ind = get(evt,'DataIndex');
pos = get(evt,'Position');

obsinds = getappdata(target,'obsinds');
obsind = obsinds(ind);

% datatipTxt = {...
%     sprintf('x: %s',num2str(pos(1)))...
%     sprintf('y: %s',num2str(pos(2)))...
%     ''...
%     sprintf('Observation: %s',num2str(obsind))...
%     };
datatipTxt = {...
    getString(message('plot_scatterhist:dataTip_x',num2str(pos(1)))), ...
    getString(message('plot_scatterhist:dataTip_y',num2str(pos(2)))), ...
    '', ...
    getString(message('plot_scatterhist:dataTip_Obs',num2str(obsind))), ...
    };
end

end % plot_scatterhist main function

% -----------------------------
function p = getrealposition(a,txt1,txt2)
p = get(a,'position');

% For non-warped axes (as in "axis square"), recalculate another way
if isequal(get(a,'WarpToFill'),'off')
    pctr = p([1 2]) + 0.5 * p([3 4]);
    xl = get(a,'xlim');
    yl = get(a,'ylim');
    
    % Use text to get coordinate (in points) of southwest corner
    set(txt1,'units','data');
    set(txt1,'position',[xl(1) yl(1)]);
    set(txt1,'units','pixels');
    pSW = get(txt1,'position');
    
    % Same for northeast corner
    set(txt2,'units','data');
    set(txt2,'position',[xl(2) yl(2)]);
    set(txt2,'units','pixels');
    pNE = get(txt2,'position');
    
    % Re-create position
    % Use min/max/abs in case one or more directions are reversed
    p = [min(pSW(1),pNE(1)), ...
         max(pSW(2),pNE(2)), ...
         abs(pNE(1)-pSW(1)), ...
         abs(pNE(2)-pSW(2))];
    p = hgconvertunits(ancestor(a,'figure'),p, ...
             'pixels','normalized',ancestor(a,'figure'));
    
    % Position to center
    p = [pctr(1)-p(3)/2, pctr(2)-p(4)/2, p(3), p(4)];
end
end % getrealposition function
