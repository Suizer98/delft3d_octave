function muppet_makeSubplot(handles,ifig,j)
% Makes subplot j in figure ifig

%% Make subplot
leftaxis=axes;

for k=1:handles.figures(ifig).figure.subplots(j).subplot.nrdatasets
    nr=muppet_findDatasetNumber(handles,handles.figures(ifig).figure.subplots(j).subplot.datasets(k).dataset.name);
    handles.figures(ifig).figure.subplots(j).subplot.datasets(k).dataset.number=nr;
end

%% In case of bars or stacked areas, data from dataset must be merged 
handles=muppet_prepareBar(handles,ifig,j);

%% Prepare subplot (sets axes etc.)
muppet_prepareSubplot(handles,ifig,j,leftaxis);

%% Plot datasets (loop through datasets in subplot)
for k=1:handles.figures(ifig).figure.subplots(j).subplot.nrdatasets 
    % Find dataset numbers
    h=muppet_plotDataset(handles,ifig,j,k);
    handles.figures(ifig).figure.subplots(j).subplot.datasets(k).dataset.handle=h;
end

%% Add text
if ~isempty(handles.figures(ifig).figure.subplots(j).subplot.subplottext.string)
    muppet_addSubplotText(handles.figures(ifig).figure,ifig,j,leftaxis);
end

%% 3D Box
switch lower(handles.figures(ifig).figure.subplots(j).subplot.type)
    case {'3d'},
        if handles.figures(ifig).figure.subplots(j).subplot.drawbox
            muppet_set3DBox(handles,ifig,j);
        end
end

%% Color Bar
if handles.figures(ifig).figure.subplots(j).subplot.plotcolorbar
    handles.figures(ifig).figure.subplots(j).subplot.shadesbar=0;
    for k=1:handles.figures(ifig).figure.subplots(j).subplot.nrdatasets
        switch lower(handles.figures(ifig).figure.subplots(j).subplot.datasets(k).dataset.plotroutine)
            case{'plotshadesmap','plotpatches'}
                handles.figures(ifig).figure.subplots(j).subplot.shadesbar=1;
        end
    end
    muppet_setColorBar(handles.figures(ifig).figure,ifig,j);
end

%% Add legend
if handles.figures(ifig).figure.subplots(j).subplot.plotlegend
    muppet_setLegend(handles.figures(ifig).figure,ifig,j);
end

%% Add vector legend
if handles.figures(ifig).figure.subplots(j).subplot.plotvectorlegend
    muppet_setVectorLegend(handles.figures(ifig).figure,ifig,j);
end

%% Add north arrow
if handles.figures(ifig).figure.subplots(j).subplot.plotnortharrow
    muppet_setNorthArrow(handles.figures(ifig).figure,ifig,j);
end

%% Add scale bar
if handles.figures(ifig).figure.subplots(j).subplot.plotscalebar==1
    muppet_setScaleBar(handles.figures(ifig).figure,ifig,j);
end

%% Set background color of axis
set(leftaxis,'Color',colorlist('getrgb','color',handles.figures(ifig).figure.subplots(j).subplot.backgroundcolor));
set(leftaxis,'Tag','axis','UserData',[ifig,j]);

