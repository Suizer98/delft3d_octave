function handles=ReadLayout(handles,SessionName,ifig);

handles.Figure(handles.ActiveFigure).Name='';

fid=fopen(SessionName);
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

txt=ReadTextFile(SessionName);

i=0;

start_figure=0;
while start_figure==0
    i=i+1;
    if strcmp(lower(txt{i}),'figure')
        start_figure=1;
    end
end

iword=i;

% Read figure properties
end_figurespecs=0;
handles.Figure=matchstruct(handles.DefaultFigureProperties,handles.Figure,ifig);
handles.Figure(ifig).Name=txt{iword+1};
while end_figurespecs==0;
    handles=ReadFigureProperties(handles,txt,iword,ifig,0,0,SessionVersion);
    end_figurespecs=strcmp(lower(txt{iword+1}),'subplot');
    iword=iword+1;
end

if strcmp(lower(txt{iword}),'outputfile')
    nosub=0;
    handles.Figure(ifig).Axis(1).Nr=0;
    handles.Figure(ifig).Axis(1).Plot(1).Dummy=0;
else
    % Read subplots
    handles.Figure(ifig).Axis(1).Dummy=0;
    handles.Figure(ifig).Axis(1).Plot(1).Dummy=0;
    [handles,iword,nosub]=ReadSubplots(handles,txt,iword,ifig,SessionVersion);
end
handles.Figure(ifig).NrSubplots=nosub;

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

for j=1:nosub
    handles.Figure(ifig).Axis(j).Nr=0;
    handles.Figure(ifig).Axis(j).Plot(1).Dummy=0;
end    
