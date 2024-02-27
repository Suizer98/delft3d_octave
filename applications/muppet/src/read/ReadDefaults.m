function handles=ReadDefaults(handles);

handles.DefaultFigureProperties=[];

txt=ReadTextFile([handles.MuppetPath 'settings' filesep 'defaults' filesep 'figureproperties.def']);
for i=1:length(txt)
    if i==1
        k=1;
    else
        k=0;
    end
    handles=ReadFigureProperties(handles,txt,i,1,k,1,1.0);
end
handles.DefaultFigureProperties.NrAnnotations=0;
handles.DefaultFigureProperties.FileName='';
handles.DefaultFigureProperties.Format='png';
handles.DefaultFigureProperties.Resolution=300;
handles.DefaultFigureProperties.Renderer='zbuffer';

handles.DefaultAnnotationOptions=[];
txt=ReadTextFile([handles.MuppetPath 'settings' filesep 'defaults' filesep 'annotations.def']);
for i=1:length(txt)
    if i==1
        k=1;
    else
        k=0;
    end
    handles=ReadAnnotationOptions(handles,txt,i,1,1,k,1);
end

txt=ReadTextFile([handles.MuppetPath 'settings' filesep 'defaults' filesep 'subplotproperties.def']);
for i=1:length(txt)
    if i==1
        k=1;
    else
        k=0;
    end
    handles=ReadSubplotProperties(handles,txt,i,1,1,k,1);
end
handles.DefaultSubplotProperties.PlotNorthArrow=0;
handles.DefaultSubplotProperties.PlotScaleBar=0;
handles.DefaultSubplotProperties.PlotLegend=0;
handles.DefaultSubplotProperties.PlotVectorLegend=0;
handles.DefaultSubplotProperties.PlotColorBar=0;

txt=ReadTextFile([handles.MuppetPath 'settings' filesep 'defaults' filesep 'plotoptions.def']);
for i=1:length(txt)
    if i==1
        k=1;
    else
        k=0;
    end
    handles=ReadPlotOptions(handles,txt,i,1,1,1,k,1);
end
