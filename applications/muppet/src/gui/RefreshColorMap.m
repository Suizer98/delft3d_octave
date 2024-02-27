function handles=RefreshColorMap(handles)

i=handles.ActiveFigure;
j=handles.ActiveSubplot;

if j>0

%    clmap=GetColors(handles.ColorMaps,handles.Figure(i).Axis(j).ColMap,64);

    if strcmpi(handles.Figure(i).Axis(j).ContourType,'limits')
        col=handles.Figure(i).Axis(j).CMin:handles.Figure(i).Axis(j).CStep:handles.Figure(i).Axis(j).CMax;
    else
%        col=handles.Figure(i).Axis(j).Contours;
        col=1:length(handles.Figure(i).Axis(j).Contours);
    end

    ncol=size(col,2)-1;
%    clmap=GetColors(handles.ColorMaps,handles.Figure(i).Axis(j).ColMap,ncol);
    clmap=GetColors(handles.ColorMaps,handles.Figure(i).Axis(j).ColMap,64);

else

    col=0:0.1:1;
    ncol=size(col,2)-1;
    clmap=GetColors(handles.ColorMaps,'jet',ncol);

end

colormap(clmap);
 
for i=1:ncol
    xp(1,i)=i-1;
    xp(2,i)=i;
    xp(3,i)=i;
    xp(4,i)=i-1;
    yp(:,i)=[0 ; 0 ; 1 ; 1];
end
zp=col(1:end-1);

axes(handles.axes1);
cla;

for i=1:ncol
    patch(xp(:,i),yp(:,i),zp(i),'clipping','on');shading flat;hold on;
end
%caxis([col(1) col(end)]);
set(handles.axes1,'xlim',[0 ncol-0.1],'ylim',[0.1 0.9]);
tick(handles.axes1,'x','none');
tick(handles.axes1,'y','none');
box off;
