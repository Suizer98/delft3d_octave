function SaveSessionFileFigures(handles,fid,ifig,iLayout)


txt=['Figure "' handles.Figure(ifig).Name '"'];
fprintf(fid,'%s \n',txt);

txt='';
fprintf(fid,'%s \n',txt);

txt=['   Orientation ' handles.Figure(ifig).Orientation];
fprintf(fid,'%s \n',txt);

txt=['   PaperSize   ' num2str(handles.Figure(ifig).PaperSize(1)) ' ' num2str(handles.Figure(ifig).PaperSize(2))];
fprintf(fid,'%s \n',txt);

txt=['   Frame       ' handles.Figure(ifig).Frame];
fprintf(fid,'%s \n',txt);

if strcmp(lower(handles.Figure(ifig).BackgroundColor),'white')==0
    txt=['   BackgroundColor "' handles.Figure(ifig).BackgroundColor '"'];
    fprintf(fid,'%s \n',txt);
end

for i=1:size(handles.Frames,2);
    if strcmp(lower(handles.Figure(ifig).Frame),lower(handles.Frames(i).Name))
        k=i;
    end
end
if strcmp(lower(handles.Figure(ifig).Frame),'none')==0
    for i=1:handles.Frames(k).TextNumber
        txt1=['   FrameText' num2str(i)]; txt1(end+1:11)=' ';
        if iLayout==0
            str=handles.Figure(ifig).FrameText(i).Text;
        else
            str='';
        end
        txt2=['"' str '"'];txt2(end+1:70)=' ';
        txt3=['"' handles.Figure(ifig).FrameText(i).Font '"'];txt3(end+1:15)=' ';
        txt4=['"' handles.Figure(ifig).FrameText(i).Angle '"'];txt4(end+1:10)=' ';
        txt5=['"' handles.Figure(ifig).FrameText(i).Weight '"'];txt5(end+1:10)=' ';
        txt6=num2str(handles.Figure(ifig).FrameText(i).Size);txt6(end+1:3)=' ';
        txt7=['"' handles.Figure(ifig).FrameText(i).Color '"'];
        fprintf(fid,'%s %s %s %s %s %s %s \n',txt1,txt2,txt3,txt4,txt5,txt6,txt7);
    end
end

txt='';
fprintf(fid,'%s \n',txt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

if handles.Figure(ifig).NrAnnotations>0
    nrsub=handles.Figure(ifig).NrSubplots-1;
else
    nrsub=handles.Figure(ifig).NrSubplots;
end

for i=1:nrsub
    SaveSessionFileSubplots(handles,fid,ifig,i,iLayout);
end

if iLayout==0
    if handles.Figure(ifig).NrAnnotations
        SaveSessionAnnotations(handles,fid,ifig);
    end
end

if iLayout==0
    str=handles.Figure(ifig).FileName;
else
    str=['figure1.' handles.Figure(ifig).Format];
end
txt=['   OutputFile "' str '"'];
fprintf(fid,'%s \n',txt);
txt=['   Format     "' handles.Figure(ifig).Format '"'];
fprintf(fid,'%s \n',txt);
txt=['   Resolution ' num2str(handles.Figure(ifig).Resolution)];
fprintf(fid,'%s \n',txt);
txt=['   Renderer   "' handles.Figure(ifig).Renderer '"'];
fprintf(fid,'%s \n',txt);
txt='';
fprintf(fid,'%s \n',txt);
txt='EndFigure';
fprintf(fid,'%s \n',txt);
txt='';
fprintf(fid,'%s \n',txt);


