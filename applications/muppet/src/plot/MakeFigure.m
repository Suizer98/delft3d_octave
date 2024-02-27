function handles=MakeFigure(handles,i,mode)

handles=PrepareFigure(handles,i,mode);

% Make frame
handles=MakeFrame(handles,i);

if handles.Figure(i).NrAnnotations>0
    nrsub=handles.Figure(i).NrSubplots-1;
else
    nrsub=handles.Figure(i).NrSubplots;
end

clfix=0;
nn=0;
% Check if colorfix is necessary. Colorfix i.c.w. painters gives problems
for j=1:nrsub
    for k=1:handles.Figure(i).Axis(j).Nr
        switch lower(handles.Figure(i).Axis(j).Plot(k).PlotRoutine),
            case {'plotcontourmap','plotcontourmaplines','plotpatches','plotshadesmap','plotvectormagnitude'},
                nn=nn+1;
                if nn>1
                    kk=strmatch(handles.Figure(i).Axis(j).ColMap,clmap);
                    if isempty(kk)
                        clfix=1;
                    end
                end
                clmap{nn}=handles.Figure(i).Axis(j).ColMap;
        end
    end
end

% Make subplots
for j=1:nrsub
    handles=MakeSubplot(handles,i,j);
    if clfix
        colorfix;
    end
end

for j=1:handles.Figure(i).NrAnnotations
    handles=AddAnnotation(handles,i,j,'new');
end

for j=1:nrsub
    if strcmp(handles.Figure(i).Axis(j).PlotType,'3d') && handles.Figure(i).Axis(j).DrawBox
        h=findobj(gcf,'Tag','framebox');
        for ii=1:length(h)
            axes(h(ii));
            set(h(ii),'HitTest','off');
        end
        h=findobj(gcf,'Tag','frametextaxis');
        for ii=1:length(h)
            axes(h(ii));
            set(h(ii),'HitTest','off');
        end
        set(gcf,'Visible','off');
        h=findobj(gcf,'Tag','logoaxis');
        for ii=1:length(h)
            axes(h(ii));
            set(h(ii),'HitTest','off');
        end
        set(gcf,'Visible','off');
    end
end

