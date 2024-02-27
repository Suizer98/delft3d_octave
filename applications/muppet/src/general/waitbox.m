function fout = waitbox(name)
%WAITBOX Display wait box.

g=guidata(findobj('Tag','MainWindow'));
icofile=[g.MuppetPath 'settings' filesep 'icons' filesep 'deltares.gif'];

type=2;

vertMargin = 0;

oldRootUnits = get(0,'Units');

set(0, 'Units', 'points');
screenSize = get(0,'ScreenSize');

axFontSize=get(0,'FactoryAxesFontSize');

pointsPerPixel = 72/get(0,'ScreenPixelsPerInch');

width = 360 * pointsPerPixel;
height = 75 * pointsPerPixel;
pos = [screenSize(3)/2-width/2 screenSize(4)/2-height/2 width height];

f = figure(...
    'Units', 'points', ...
    'BusyAction', 'queue', ...
    'Position', pos, ...
    'Resize','off', ...
    'CreateFcn','', ...
    'NumberTitle','off', ...
    'IntegerHandle','off', ...
    'MenuBar', 'none', ...
    'Visible','off', ...
    'Tag','waitbox');

axNorm=[.05 .3 .9 .1];
axPos=axNorm.*[pos(3:4),pos(3:4)] + [0 vertMargin 0 0];

h = axes('XLim',[0 100],...
    'YLim',[0 1],...
    'Units','Points',...
    'FontSize', axFontSize,...
    'Position',axPos,...
    'XTickMode','manual',...
    'YTickMode','manual',...
    'XTick',[],...
    'YTick',[],...
    'XTickLabelMode','manual',...
    'XTickLabel',[],...
    'YTickLabelMode','manual',...
    'YTickLabel',[]);
set(h,'box','off');
axis off;
set(f,'WindowStyle','modal');
tHandle=title(name);
tHandle=get(h,'title');
oldTitleUnits=get(tHandle,'Units');
set(tHandle,...
    'Units',      'points',...
    'String',     name);

tExtent=get(tHandle,'Extent');
set(tHandle,'Units',oldTitleUnits);

titleHeight=tExtent(4)+axPos(2)+axPos(4)+5;
if titleHeight>pos(4)
    pos(4)=titleHeight;
    pos(2)=screenSize(4)/2-pos(4)/2;
    figPosDirty=logical(1);
else
    figPosDirty=logical(0);
end

if tExtent(3)>pos(3)*1.10;
    pos(3)=min(tExtent(3)*1.10,screenSize(3));
    pos(1)=screenSize(3)/2-pos(3)/2;

    axPos([1,3])=axNorm([1,3])*pos(3);
    set(h,'Position',axPos);

    figPosDirty=logical(1);
end

if figPosDirty
    set(f,'Position',pos);
end

set(f,'HandleVisibility','callback','visible','on');

if ~isempty(icofile)
    fh = get(f,'JavaFrame'); % Get Java Frame 
    fh.setFigureIcon(javax.swing.ImageIcon(icofile));
end

set(0, 'Units', oldRootUnits);
drawnow;

if nargout==1,
    fout = f;
end
