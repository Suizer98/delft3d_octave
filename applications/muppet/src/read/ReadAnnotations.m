function [handles,itxt]=ReadAnnotations(handles,txt,itxt,i);

nann=0;
end_annotations=false;
handles.Figure(i).Annotation.Name=[];

while end_annotations==0

    end_annotation=false;

    while end_annotation==0
        switch lower(txt{itxt}),
            case {'annotation'},
                nann=nann+1;
                handles.Figure(i).Annotation=matchstruct(handles.DefaultAnnotationOptions,handles.Figure(i).Annotation,nann);
                handles.Figure(i).Annotation(nann).Name=txt{itxt+1};
                handles.Figure(i).Annotation(nann).NrTextLines=0;
                switch lower(txt{itxt+1}(1:4)),
                    case {'text'}
                        handles.Figure(i).Annotation(nann).Type='textbox';
                    case {'line'}
                        handles.Figure(i).Annotation(nann).Type='line';
                    case {'arro'}
                        handles.Figure(i).Annotation(nann).Type='arrow';
                    case {'doub'}
                        handles.Figure(i).Annotation(nann).Type='doublearrow';
                    case {'rect'}
                        handles.Figure(i).Annotation(nann).Type='rectangle';
                    case {'elli'}
                        handles.Figure(i).Annotation(nann).Type='ellipse';
                end
        end
        if nann>0
            handles=ReadAnnotationOptions(handles,txt,itxt,i,nann,0,0);
        end

        end_annotation=strcmp(lower(txt{itxt}),'endannotation');
        itxt=itxt+1;

    end
    if strcmp(lower(txt{itxt}),'endannotations')
        end_annotations=1;
        itxt=itxt+1;
    end

end

handles.Figure(i).NrAnnotations=nann;
