function handles=muppet_addSubplot(handles,position,addsubplotannotations)

ifig=handles.activefigure;

if ~addsubplotannotations

    % Add subplot

    if handles.figures(ifig).figure.nrannotations==0
        i0=handles.figures(ifig).figure.nrsubplots;
    else
        i0=handles.figures(ifig).figure.nrsubplots-1;
    end        

    s.name=['Subplot ' num2str(i0+1)];
    s.position=position;
    [s,ok]=gui_newWindow(s, 'xmldir', handles.xmlguidir, 'xmlfile', 'newsubplot.xml','iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);
    if ok
        name=s.name;
        position=s.position;
    else        
        return
    end

    handles.figures(ifig).figure.nrsubplots=handles.figures(ifig).figure.nrsubplots+1;
    nrsub=handles.figures(ifig).figure.nrsubplots;
    
    if handles.figures(ifig).figure.nrannotations==0
        isub=nrsub;
    else
        % Shift annotation layer to last position
        handles.figures(ifig).figure.subplots(nrsub).subplot=handles.figures(ifig).figure.subplots(nrsub-1).subplot;
        isub=handles.figures(ifig).figure.nrsubplots-1;
    end
    
    handles.activesubplot=isub;
    
    handles.figures(ifig).figure.subplots(isub).subplot=muppet_setDefaultAxisProperties;
    handles.figures(ifig).figure.subplots(isub).subplot.name=name;
    handles.figures(ifig).figure.subplots(isub).subplot.position=position;
    
    handles.activedatasetinsubplot=1;
    
else
    
    % Add annotation layer

    handles.figures(ifig).figure.nrsubplots=handles.figures(ifig).figure.nrsubplots+1;
    isub=handles.figures(ifig).figure.nrsubplots;
    
    if isub==1
        handles.activesubplot=1;
    end
    
    handles.figures(ifig).figure.subplots(isub).subplot=muppet_setDefaultAxisProperties;
    
    handles.figures(ifig).figure.subplots(isub).subplot.name='Annotations';
    handles.figures(ifig).figure.subplots(isub).subplot.type='Annotations';
    handles.figures(ifig).figure.subplots(isub).subplot.position=[0 0 0 0];
    
    handles.figures(ifig).figure.subplots(isub).subplot.nrdatasets=handles.figures(ifig).figure.nrannotations;

    handles.activedatasetinsubplot=1;

end

handles=muppet_updateSubplotNames(handles);
handles=muppet_updateDatasetInSubplotNames(handles);
muppet_refreshColorMap(handles);
