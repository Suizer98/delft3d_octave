function handles=ReadSessionFile(handles,SessionFile)

fid=fopen(SessionFile);
tx0=fgets(fid);
if and(ischar(tx0), size(tx0>0))
    pos1=strfind(tx0,'Muppet v');
    pos2=strfind(tx0,'Muppet-GUI v');
    if pos1>0
        SessionVersion=str2num(tx0(pos1+8:pos1+11));
    elseif pos2>0
        SessionVersion=str2num(tx0(pos2+12:pos2+15));
    else
        SessionVersion=1.0;
    end
else
    SessionVersion=1.0;
end
fclose(fid);

txt=ReadTextFile(SessionFile);
 
% Read dataset properties from session file
[handles.DataProperties,iword,noset]=ReadDataProperties(txt);
handles.NrAvailableDatasets=noset;

% Read combined dataset properties from session file
[handles.CombinedDatasetProperties,iword,nocombset]=ReadCombinedDataProperties(txt);
handles.NrCombinedDatasets=nocombset;

for j=1:nocombset
    k=noset+j;
    handles.DataProperties(k).Name=handles.CombinedDatasetProperties(j).Name;
end

ifig=0;

end_file=0;

while end_file==0
    
    ifig=ifig+1;

    handles.Figure(ifig).NrAnnotations=0;
    
    % Read figure properties
    
    end_figurespecs=0;
    
    handles.Figure=matchstruct(handles.DefaultFigureProperties,handles.Figure,ifig);
    handles.Figure(ifig).Name=txt{iword+1};
    while end_figurespecs==0;
        handles=ReadFigureProperties(handles,txt,iword,ifig,0,0,SessionVersion);
        end_figurespecs = strcmp(lower(txt{iword+1}),'subplot') | strcmp(lower(txt{iword+1}),'outputfile') | ...
                          strcmp(lower(txt{iword+1}),'annotations');
        iword=iword+1;
    end

    if strcmp(lower(txt{iword}),'outputfile') | strcmp(lower(txt{iword}),'annotations')
        handles.Figure(ifig).NrSubplots=0;
        handles.Figure(ifig).Axis(1).Nr=0;
    else
        % Read subplots
        [handles,iword,nosub]=ReadSubplots(handles,txt,iword,ifig,SessionVersion);
        handles.Figure(ifig).NrSubplots=nosub;
    end

    if SessionVersion<3.16
        noframes=size(handles.Frames,2);
        for i=1:noframes
            fr{i}=handles.Frames(i).Name;
        end
        k=strmatch(lower(handles.Figure(ifig).Frame),lower(fr),'exact');
        if handles.Frames(k).Number>0
            for kk=1:handles.Figure(ifig).NrSubplots
                handles.Figure(ifig).Axis(kk).Position(1)=handles.Figure(ifig).Axis(kk).Position(1)+1;
                handles.Figure(ifig).Axis(kk).Position(2)=handles.Figure(ifig).Axis(kk).Position(2)+1;
                handles.Figure(ifig).Axis(kk).ColorBarPosition(1)=handles.Figure(ifig).Axis(kk).ColorBarPosition(1)+1;
                handles.Figure(ifig).Axis(kk).ColorBarPosition(2)=handles.Figure(ifig).Axis(kk).ColorBarPosition(2)+1;
                handles.Figure(ifig).Axis(kk).ScaleBar(1)=handles.Figure(ifig).Axis(kk).ScaleBar(1)+1;
                handles.Figure(ifig).Axis(kk).ScaleBar(2)=handles.Figure(ifig).Axis(kk).ScaleBar(2)+1;
                handles.Figure(ifig).Axis(kk).NorthArrow(1)=handles.Figure(ifig).Axis(kk).NorthArrow(1)+1;
                handles.Figure(ifig).Axis(kk).NorthArrow(2)=handles.Figure(ifig).Axis(kk).NorthArrow(2)+1;
                handles.Figure(ifig).Axis(kk).VectorLegendPosition=handles.Figure(ifig).Axis(kk).VectorLegendPosition+1;
            end
        end
        if strcmp(handles.Figure(ifig).Orientation,'l')
            if handles.Figure(ifig).PaperSize(1)==27.3 & handles.Figure(ifig).PaperSize(2)==18.4
                handles.Figure(ifig).PaperSize=[29.7 21];
            end
        else
            if handles.Figure(ifig).PaperSize(1)==18.4 & handles.Figure(ifig).PaperSize(2)==27.3
                handles.Figure(ifig).PaperSize=[21 29.7];
            end
        end
    end    
    
    if strcmp(lower(txt{iword}),'annotations')
        [handles,iword]=ReadAnnotations(handles,txt,iword,ifig);
        nosub=handles.Figure(ifig).NrSubplots+1;
        handles.Figure(ifig).NrSubplots=nosub;
        handles.Figure(ifig).Axis=matchstruct(handles.DefaultSubplotProperties,handles.Figure(ifig).Axis,nosub);
        handles.Figure(ifig).Axis(nosub).Name='Annotations';
        handles.Figure(ifig).Axis(nosub).PlotType='Annotations';
        handles.Figure(ifig).Axis(nosub).Position=[0 0 0 0];
        handles.Figure(ifig).Axis(nosub).Nr=handles.Figure(ifig).NrAnnotations;
        for k=1:handles.Figure(ifig).NrAnnotations
            handles.Figure(ifig).Axis(nosub).Plot(k).Name=handles.Figure(ifig).Annotation(k).Name;
        end
    else
        handles.Figure(ifig).NrAnnotations=0;
    end

    % Read export data
    [handles,iword]=ReadOutputProperties(handles,txt,iword,ifig);
    if iword>=size(txt,2)
        end_file=1;
    end

end

handles.NrFigures=ifig;
