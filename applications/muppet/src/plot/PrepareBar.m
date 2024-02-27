function handles=PrepareBar(handles,i,j)

PlotOptions=handles.Figure(i).Axis(j).Plot;

nodat=handles.Figure(i).Axis(j).Nr;

BarY=[];
StackedAreaY=[];

handles.Figure(i).Axis(j).xtcklab=[];

nbar=0;
nstackedarea=0;
for k=1:nodat
    ii=PlotOptions(k).AvailableDatasetNr;
    handles.Figure(i).Axis(j).Plot(k).BarNr=0;
    handles.Figure(i).Axis(j).Plot(k).AreaNr=0;
    switch lower(PlotOptions(k).PlotRoutine),
        case {'plothistogram'}
            nbar=nbar+1;
            handles.Figure(i).Axis(j).Plot(k).BarNr=nbar;
            BarY(:,nbar)=handles.DataProperties(ii).y;
            if strcmp(lower(handles.DataProperties(ii).Type),'bar')
                handles.Figure(i).Axis(j).xtcklab=handles.DataProperties(ii).XTickLabel;
            else
                handles.Figure(i).Axis(j).xtcklab=[];
            end
        case {'plotstackedarea'}
            nstackedarea=nstackedarea+1;
            handles.Figure(i).Axis(j).Plot(k).AreaNr=nstackedarea;
            StackedAreaY(:,nstackedarea)=handles.DataProperties(ii).y;
    end
end

for k=1:nodat
    if handles.Figure(i).Axis(j).Plot(k).BarNr>0
        handles.Figure(i).Axis(j).Plot(k).NrBars=nbar;
    end
    if handles.Figure(i).Axis(j).Plot(k).AreaNr>0
        handles.Figure(i).Axis(j).Plot(k).NrAreas=nstackedarea;
    end
end

handles.BarY=BarY;
handles.StackedAreaY=StackedAreaY;


