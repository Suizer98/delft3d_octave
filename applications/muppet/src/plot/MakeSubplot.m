function handles=MakeSubplot(handles,i,j)

Ax=handles.Figure(i).Axis(j);

nodat=Ax.Nr;

LeftAxis=axes;

for k=1:nodat
    handles.Figure(i).Axis(j).Plot(k).AvailableDatasetNr=FindDatasetNr(Ax.Plot(k).Name,handles.DataProperties);
end

handles=PrepareBar(handles,i,j);

PrepareSubplot(handles,i,j,LeftAxis);

for k=1:nodat    
    handles=PlotDataset(handles,i,j,k,'new');
end

switch lower(Ax.PlotType),
    case {'3d'},
        if Ax.DrawBox
            Set3DBox(handles.Figure(i),Ax);
        end
end

ColBar=[];
if Ax.PlotColorBar==1
    handles.Figure(i).Axis(j).ShadesBar=0;
    for k=1:nodat
        switch lower(Ax.Plot(k).PlotRoutine),
            case{'plotshadesmap','plotpatches'}
                handles.Figure(i).Axis(j).ShadesBar=1;
        end
    end
    ColBar=SetColorBar(handles,i,j);
end

Leg=[];
if Ax.PlotLegend
    Leg=SetLegend(handles,i,j);
end

VecLeg=[];
if Ax.PlotVectorLegend
    VecLeg=SetVectorLegend(handles,i,j);
end

NorthArrow=[];
if Ax.PlotNorthArrow
    NorthArrow=SetNorthArrow(handles,i,j);
end

ScaleBar=[];
if Ax.PlotScaleBar==1
    ScaleBar=SetScaleBar(handles,i,j);
end

set(LeftAxis,'Color',FindColor(Ax.BackgroundColor));
set(LeftAxis,'Tag','axis','UserData',[i,j]);

handles.Figure(i).Axis(j).ColorBarHandle=ColBar;
handles.Figure(i).Axis(j).LegendHandle=Leg;
handles.Figure(i).Axis(j).VectorLegendHandle=VecLeg;
handles.Figure(i).Axis(j).NorthArrowHandle=NorthArrow;
handles.Figure(i).Axis(j).ScaleBarHandle=ScaleBar;

