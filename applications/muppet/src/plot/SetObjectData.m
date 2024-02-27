function SetObjectData(h,i,j,k,tag)

handles=guidata(findobj('Name','Muppet'));
set(h,'UserData',[i,j,k]);
set(h,'Tag',tag);
set(h,'ButtonDownFcn',{@SelectDataset});
set(h,'SelectionHighlight','off');
ObjectData.PlotRoutine=handles.Figure(i).Axis(j).Plot(k).PlotRoutine;
ObjectData.i=i;
ObjectData.j=j;
ObjectData.k=k;
for ii=1:length(h)
    setappdata(h(ii),'ObjectData',ObjectData);
end
