function SaveSessionFileAnnotations(handles,fid,ifig)

txt=['   Annotations'];
fprintf(fid,'%s \n',txt);

txt='';
fprintf(fid,'%s \n',txt);

for k=1:handles.Figure(ifig).NrAnnotations

    ann=handles.Figure(ifig).Annotation(k);

    switch ann.Type,

        case 'textbox'
            txt=['      Annotation "' ann.Name '"'];
            fprintf(fid,'%s\n',txt);
            txt=['         Position        ' num2str(ann.Position)];
            fprintf(fid,'%s \n',txt);
            if ann.Box
                txt=['         Box             yes'];
                fprintf(fid,'%s \n',txt);
                if ~strcmp(lower(ann.BackgroundColor),'white')
                    txt=['         BackgroundColor "' ann.BackgroundColor '"'];
                    fprintf(fid,'%s \n',txt);
                end
                if ~strcmp(lower(ann.LineColor),'black')
                    txt=['         LineColor       "' ann.LineColor '"'];
                    fprintf(fid,'%s \n',txt);
                end
            else
                txt=['         Box             no'];
                fprintf(fid,'%s \n',txt);
            end
            if ~strcmp(lower(ann.LineStyle),'-')
                txt=['         LineStyle       ' num2str(ann.LineStyle)];
                fprintf(fid,'%s \n',txt);
            end
            txt=['         LineWidth       ' num2str(ann.LineWidth)];
            fprintf(fid,'%s \n',txt);
            if ~strcmp(lower(ann.Font),'helvetica')
                txt=['         Font            "' ann.Font '"'];
                fprintf(fid,'%s \n',txt);
            end
            if ann.FontSize~=0.5
                txt=['         FontSize        ' num2str(ann.FontSize)];
                fprintf(fid,'%s \n',txt);
            end
            if ~strcmp(lower(ann.FontWeight),'normal')
                txt=['         FontWeight      "' ann.FontWeight '"'];
                fprintf(fid,'%s \n',txt);
            end
            if ~strcmp(lower(ann.FontAngle),'normal')
                txt=['         FontAngle       "' ann.FontAngle '"'];
                fprintf(fid,'%s \n',txt);
            end
            if ~strcmp(lower(ann.FontColor),'black')
                txt=['         FontColor       "' ann.FontColor '"'];
                fprintf(fid,'%s \n',txt);
            end
            if ~strcmp(lower(ann.HorAl),'left')
                txt=['         HorAlignment    ' ann.HorAl];
                fprintf(fid,'%s \n',txt);
            end
            str=cellstr(ann.String);
            for kk=1:length(str)
                txt=['         Text            "' str{kk} '"'];
                fprintf(fid,'%s\n',txt);
            end
            txt=['      EndAnnotation'];
            fprintf(fid,'%s\n',txt);
            txt=[''];
            fprintf(fid,'%s\n',txt);

        case 'line'
            txt=['      Annotation  "' ann.Name '"'];
            fprintf(fid,'%s\n',txt);
            txt=['         Position        ' num2str(ann.Position)];
            fprintf(fid,'%s \n',txt);
            if ~strcmp(lower(ann.LineColor),'black')
                txt=['         LineColor       "' ann.LineColor '"'];
                fprintf(fid,'%s \n',txt);
            end
            if ~strcmp(lower(ann.LineStyle),'-')
                txt=['         LineStyle       "' num2str(ann.LineStyle) '"'];
                fprintf(fid,'%s \n',txt);
            end
            txt=['         LineWidth       ' num2str(ann.LineWidth)];
            fprintf(fid,'%s \n',txt);
            txt=['      EndAnnotation'];
            fprintf(fid,'%s\n',txt);
            txt=[''];
            fprintf(fid,'%s\n',txt);

        case 'arrow'
            txt=['      Annotation "' ann.Name '"'];
            fprintf(fid,'%s\n',txt);
            txt=['         Position        ' num2str(ann.Position)];
            fprintf(fid,'%s \n',txt);
            if ~strcmp(lower(ann.LineColor),'black')
                txt=['         LineColor       "' ann.LineColor '"'];
                fprintf(fid,'%s \n',txt);
            end
            if ~strcmp(lower(ann.LineStyle),'-')
                txt=['         LineStyle       "' num2str(ann.LineStyle) '"'];
                fprintf(fid,'%s \n',txt);
            end
            txt=['         LineWidth       ' num2str(ann.LineWidth)];
            fprintf(fid,'%s \n',txt);
            txt=['         HeadStyle       "' num2str(ann.Head1Style) '"'];
            fprintf(fid,'%s \n',txt);
            if ann.Head1Width~=6
                txt=['         HeadWidth       ' num2str(ann.Head1Width)];
                fprintf(fid,'%s \n',txt);
            end
            if ann.Head1Length~=6
                txt=['         HeadLength      ' num2str(ann.Head1Length)];
                fprintf(fid,'%s \n',txt);
            end
            txt=['      EndAnnotation'];
            fprintf(fid,'%s\n',txt);
            txt=[''];
            fprintf(fid,'%s\n',txt);

        case 'doublearrow'
            txt=['      Annotation "' ann.Name '"'];
            fprintf(fid,'%s\n',txt);
            txt=['         Position        ' num2str(ann.Position)];
            fprintf(fid,'%s \n',txt);
            if ~strcmp(lower(ann.LineColor),'black')
                txt=['         LineColor       "' ann.LineColor '"'];
                fprintf(fid,'%s \n',txt);
            end
            if ~strcmp(lower(ann.LineStyle),'-')
                txt=['         LineStyle       "' num2str(ann.LineStyle) '"'];
                fprintf(fid,'%s \n',txt);
            end
            txt=['         LineWidth       ' num2str(ann.LineWidth)];
            fprintf(fid,'%s \n',txt);
            txt=['         Head1Style      "' num2str(ann.Head1Style) '"'];
            fprintf(fid,'%s \n',txt);
            if ann.Head1Width~=6
                txt=['         Head1Width      ' num2str(ann.Head1Width)];
                fprintf(fid,'%s \n',txt);
            end
            if ann.Head1Length~=6
                txt=['         Head1Length     ' num2str(ann.Head1Length)];
                fprintf(fid,'%s \n',txt);
            end
            txt=['         Head2Style      "' num2str(ann.Head2Style) '"'];
            fprintf(fid,'%s \n',txt);
            if ann.Head2Width~=6
                txt=['         Head2Width      ' num2str(ann.Head2Width)];
                fprintf(fid,'%s \n',txt);
            end
            if ann.Head1Length~=6
                txt=['         Head2Length     ' num2str(ann.Head2Length)];
                fprintf(fid,'%s \n',txt);
            end
            txt=['      EndAnnotation'];
            fprintf(fid,'%s\n',txt);
            txt=[''];
            fprintf(fid,'%s\n',txt);

        case {'rectangle','ellipse'}
            txt=['      Annotation "' ann.Name '"'];
            fprintf(fid,'%s\n',txt);
            txt=['         Position        ' num2str(ann.Position)];
            fprintf(fid,'%s \n',txt);
            txt=['         BackgroundColor "' ann.BackgroundColor '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         LineColor       "' ann.LineColor '"'];
            fprintf(fid,'%s \n',txt);
            if ~strcmp(lower(ann.LineStyle),'-')
                txt=['         LineStyle       ' num2str(ann.LineStyle)];
                fprintf(fid,'%s \n',txt);
            end
            txt=['         LineWidth       ' num2str(ann.LineWidth)];
            fprintf(fid,'%s \n',txt);
            txt=['      EndAnnotation'];
            fprintf(fid,'%s\n',txt);
            txt=[''];
            fprintf(fid,'%s\n',txt);
    end
end

txt=['   EndAnnotations'];
fprintf(fid,'%s \n',txt);

txt='';
fprintf(fid,'%s \n',txt);
