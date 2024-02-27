function muppet_makeFigure(handles,ifig,mode)

% Delete existing figure
switch mode
    case{'export','guiexport'}
    otherwise
        figh=findobj('tag','figure','userdata',ifig);
        delete(figh);
end

a=get(0,'ScreenSize');
asprat=handles.figures(ifig).figure.width/handles.figures(ifig).figure.height;
if asprat<a(3)/a(4)
    y1=0.88*a(4);
    cm2pix=y1/handles.figures(ifig).figure.height;
else
    x1=0.88*a(3);
    cm2pix=x1/handles.figures(ifig).figure.width;
end
ScreenPixelsPerInch=get(0,'ScreenPixelsPerInch');

% Compute some of the figure's size and unit parameters
if strcmp(mode,'preview')
    % Preview on screen
    handles.figures(ifig).figure.units='pixels';
    handles.figures(ifig).figure.cm2pix=cm2pix;
    handles.figures(ifig).figure.fontreduction=2.5*cm2pix/ScreenPixelsPerInch;
    handles.figures(ifig).figure.zoom='none';
    handles.figures(ifig).figure.export=0;    
else
    % Export to file
    
    if ~verLessThan('matlab', '8.4')
        handles.figures(ifig).figure.fontreduction=1;
        handles.figures(ifig).figure.units='pixels';
        handles.figures(ifig).figure.cm2pix=cm2pix;
    else
        handles.figures(ifig).figure.units='centimeters';
        handles.figures(ifig).figure.cm2pix=1;
        handles.figures(ifig).figure.fontreduction=1;
    end
    
    handles.figures(ifig).figure.export=1; 
    
end

fig=handles.figures(ifig).figure;

% Prepare figure (i.e. make figure, toolbar etc.)
figh=muppet_prepareFigure(handles,ifig,mode);
fig.handle=figh;

% Set figures application data (used for editing figure)
fig.number=ifig;
fig.changed=0;
fig.annotationschanged=0;
for j=1:fig.nrsubplots
    fig.subplots(j).subplot.colorbar.changed=0;
    fig.subplots(j).subplot.legend.changed=0;
    fig.subplots(j).subplot.vectorlegend.changed=0;
    fig.subplots(j).subplot.northarrow.changed=0;
    fig.subplots(j).subplot.scalebar.changed=0;
    fig.subplots(j).subplot.limitschanged=0;
    fig.subplots(j).subplot.positionchanged=0;
    fig.subplots(j).subplot.annotationsadded=0;
    fig.subplots(j).subplot.annotationschanged=0;
end
setappdata(figh,'figure',fig);
setappdata(figh,'cm2pix',handles.figures(ifig).figure.cm2pix);

% Make frame
if fig.useframe
    muppet_makeFrame(handles,ifig);
end

% Check if colorfix is necessary. Colorfix i.c.w. painters gives problems
clfix=0;
nn=0;
for j=1:fig.nrsubplots
    for k=1:fig.subplots(j).subplot.nrdatasets
        switch lower(fig.subplots(j).subplot.datasets(k).dataset.plotroutine)
            case {'contour map','contour map and lines','patches','shades map','vector magnitude','kubint'}
                nn=nn+1;
                if nn>1
                    kk=strmatch(fig.subplots(j).subplot.colormap,clmap);
                    if isempty(kk)
                        clfix=1;
                    end
                end
                clmap{nn}=fig.subplots(j).subplot.colormap;
        end
    end
end

% Make subplots
for j=1:fig.nrsubplots
    switch fig.subplots(j).subplot.type
        case{'annotation'}
            for k=1:fig.subplots(j).subplot.nrdatasets
                muppet_plotDataset(handles,ifig,j,k);
            end
        otherwise
            muppet_makeSubplot(handles,ifig,j);
            if clfix
                colorfix;
            end
    end
end

% for j=1:fig.nrsubplots
%     % Do stuff with boxes for 3D plots, not sure anymore why this is
%     % necessary ...
%     if strcmp(fig.subplots(j).subplot.type,'3d') && fig.subplots(j).subplot.drawbox
%         h=findobj(gcf,'Tag','framebox');
%         for ii=1:length(h)
%             axes(h(ii));
%             set(h(ii),'HitTest','off');
%         end
%         h=findobj(gcf,'Tag','frametextaxis');
%         for ii=1:length(h)
%             axes(h(ii));
%             set(h(ii),'HitTest','off');
%         end
%         set(gcf,'Visible','off');
%         h=findobj(gcf,'Tag','logoaxis');
%         for ii=1:length(h)
%             axes(h(ii));
%             set(h(ii),'HitTest','off');
%         end
%         set(gcf,'Visible','off');
%     end
% end

