function [handles,itxt]=ReadOutputProperties(handles,txt,itxt,NoFig);

handles.Figure(NoFig).FileName='default.png';
handles.Figure(NoFig).Format='png';
handles.Figure(NoFig).Resolution=300;
handles.Figure(NoFig).Renderer='zbuffer';

end_output=0;


while end_output==0
    switch lower(txt{itxt})
        case{'outputfile'},
            handles.Figure(NoFig).FileName=txt{itxt+1};
        case{'format'},
            handles.Figure(NoFig).Format=txt{itxt+1};
        case{'resolution'},
            handles.Figure(NoFig).Resolution=str2num(txt{itxt+1});
        case{'renderer'},
            handles.Figure(NoFig).Renderer=txt{itxt+1};
    end
    
    stopstr={'endfigure'};
        
    end_output=max(strcmp(lower(txt{itxt}),stopstr));

    if itxt>=length(txt)
        end_output=1;
    end
    
    itxt=itxt+1;

end
