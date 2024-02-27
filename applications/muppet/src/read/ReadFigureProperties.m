function handles=ReadFigureProperties(handles,txt,itxt,i,ifirst,idef,SessionVersion);

if idef
    h=handles.DefaultFigureProperties;
else
    h=handles.Figure(i);
end

if ifirst

    for j=1:20
        h.FrameText(j).Text='';
        h.FrameText(j).Color='black';
        h.FrameText(j).Font='Helvetica';
        h.FrameText(j).Angle='normal';
        h.FrameText(j).Size=10;
        h.FrameText(j).Weight='normal';
    end

    h.LogoFile='none';
    h.PaperSize=[18.4 27.3];
    h.BackgroundColor='white';

end

switch lower(txt{itxt})
    case{'orientation'},
        h.Orientation=txt{itxt+1}(1);
    case{'papersize'},
        h.PaperSize(1)=str2num(txt{itxt+1});
        h.PaperSize(2)=str2num(txt{itxt+2});
    case{'frame'},
        h.Frame=txt{itxt+1};
    case{'backgroundcolor'},
        h.BackgroundColor=txt{itxt+1};
end

tx=lower(txt{itxt});
if length(tx)>=9 && strcmp(tx(1:9),'frametext')
    nr=str2num(tx(10:end));
    if SessionVersion>=2.9
        h.FrameText(nr).Text=txt{itxt+1};
        h.FrameText(nr).Font=txt{itxt+2};
        h.FrameText(nr).Angle=txt{itxt+3};
        h.FrameText(nr).Weight=txt{itxt+4};
        h.FrameText(nr).Size=str2num(txt{itxt+5});
        h.FrameText(nr).Color=txt{itxt+6};
    else
        h.FrameText(nr).Text=txt{itxt+1};
        h.FrameText(nr).Font=txt{itxt+2};
        h.FrameText(nr).Angle=txt{itxt+3};
        h.FrameText(nr).Size=str2num(txt{itxt+4});
    end
end

if isstruct(h)
    names=fieldnames(h);
    for ii=1:length(names)
        v=getfield(h,names{ii});
        if idef
            handles.DefaultFigureProperties.(names{ii})=v;
        else
            handles.Figure(i).(names{ii})=v;
        end
    end
end

