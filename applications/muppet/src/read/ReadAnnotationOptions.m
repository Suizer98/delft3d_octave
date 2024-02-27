function handles=ReadAnnotationOptions(handles,txt,itxt,i,m,ifirst,idef)

h=[];

if idef
    h=handles.DefaultAnnotationOptions;
else
    h=handles.Figure(i).Annotation(m);
end

if ifirst
    h.Position=[0 0 0 0];
    h.LineColor=       'black';
    h.LineStyle=       '-';
    h.LineWidth=       2;
    h.Head1Style=      'plain';
    h.Head1Width=      6;
    h.Head1Length=     6;
    h.Head2Style=      'plain';
    h.Head2Width=      6;
    h.Head2Length=     6;
    h.BackgroundColor= 'white';
    h.FontColor=       'black';
    h.Font=            'Helvetica';
    h.FontSize=        8;
    h.FontWeight=      'normal';
    h.FontAngle=       'normal';
    h.FontColor=       'black';
    h.HorAl=           'left';
    h.String=          '';
    h.Box=             0;
end

switch lower(txt{itxt}),
    
    case {'position'},
            h.Position(1)=str2num(txt{itxt+1});
            h.Position(2)=str2num(txt{itxt+2});
            h.Position(3)=str2num(txt{itxt+3});
            h.Position(4)=str2num(txt{itxt+4});
        
    case {'linestyle'},
        h.LineStyle=txt{itxt+1};

    case {'linewidth'},
        h.LineWidth=str2num(txt{itxt+1});

    case {'linecolor'},
        if isnan(str2double(txt{itxt+1}))
            h.LineColor=txt{itxt+1};
        else
            h.LineColor=[];
            h.LineColor(1)=str2num(txt{itxt+1});
            h.LineColor(2)=str2num(txt{itxt+2});
            h.LineColor(3)=str2num(txt{itxt+3});
        end

    case {'fontcolor'},
        if isnan(str2double(txt{itxt+1}))
            h.FontColor=txt{itxt+1};
        else
            h.FontColor=[];
            h.FontColor(1)=str2num(txt{itxt+1});
            h.FontColor(2)=str2num(txt{itxt+2});
            h.FontColor(3)=str2num(txt{itxt+3});
        end

    case {'backgroundcolor'},
        if isnan(str2double(txt{itxt+1}))
            h.BackgroundColor=txt{itxt+1};
        else
            h.BackgroundColor=[];
            h.BackgroundColor(1)=str2num(txt{itxt+1});
            h.BackgroundColor(2)=str2num(txt{itxt+2});
            h.BackgroundColor(3)=str2num(txt{itxt+3});
        end

    case {'font'},
        h.Font=txt{itxt+1};

    case {'fontsize'},
        h.FontSize=str2num(txt{itxt+1});

    case {'fontweight'},
        h.FontWeight=txt{itxt+1};

    case {'fontangle'},
        h.FontAngle=txt{itxt+1};

    case {'fontcolor'},
        if isnan(str2double(txt{itxt+1}))
            h.FontColor=txt{itxt+1};
        else
            h.FontColor=[];
            h.FontColor(1)=str2num(txt{itxt+1});
            h.FontColor(2)=str2num(txt{itxt+2});
            h.FontColor(3)=str2num(txt{itxt+3});
        end

    case {'horalignment'},
        h.HorAl=txt{itxt+1};

    case {'veralignment'},
        h.VerAl=txt{itxt+1};

    case {'headstyle','head1style'},
        h.Head1Style=txt{itxt+1};

    case {'headwidth','head1width'},
        h.Head1Width=str2num(txt{itxt+1});

    case {'headlength','head1length'},
        h.Head1Length=str2num(txt{itxt+1});
        
    case {'head2style'},
        h.Head2Style=txt{itxt+1};

    case {'head2width'},
        h.Head2Width=str2num(txt{itxt+1});

    case {'head2length'},
        h.Head2Length=str2num(txt{itxt+1});

    case {'text'},
        h.NrTextLines=h.NrTextLines+1;
        k=h.NrTextLines;
        h.String{k}=txt{itxt+1};

    case {'box'},
        if strcmp(lower(txt{itxt+1}),'yes')
            h.Box=1;
        else
            h.Box=0;
        end
end

if isstruct(h)
    names=fieldnames(h);
    for ii=1:length(names)
        v=getfield(h,names{ii});
        if idef
            handles.DefaultAnnotationOptions.(names{ii})=v;
        else
            handles.Figure(i).Annotation(m).(names{ii})=v;
        end
    end
end
