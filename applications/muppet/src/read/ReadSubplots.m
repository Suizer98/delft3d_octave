function [handles,itxt,j]=ReadSubplots(handles,txt,itxt,i,SessionVersion)

j=0;
end_subplots=false;

handles.Figure(i).Axis(1).Plot(1).Dummy=[];

while end_subplots==0

    j=j+1;
    
    % Read subplot properties
    end_subplotspecs=0;
    handles.Figure(i).Axis=matchstruct(handles.DefaultSubplotProperties,handles.Figure(i).Axis,j);
    handles.Figure(i).Axis(j).Name=txt{itxt+1};
    while end_subplotspecs==0;
        handles=ReadSubplotProperties(handles,txt,itxt,i,j,0,0);
        end_subplotspecs=or(strcmp(lower(txt{itxt+1}),'dataset'),strcmp(lower(txt{itxt+1}),'endsubplot'));
        itxt=itxt+1;
    end
   
    if strcmp(lower(txt{itxt}),'endsubplot')
        itxt=itxt-1;
    end

    k=0;
    end_datasets=false;
    
    while end_datasets==0

        % Read plot options
        end_dataset=false;

        while end_dataset==0
            switch lower(txt{itxt}),
                case {'dataset'},
                    k=k+1;
                    handles.Figure(i).Axis(j).Plot(k).Dummy=[];
                    handles.Figure(i).Axis(j).Plot=matchstruct(handles.DefaultPlotOptions,handles.Figure(i).Axis(j).Plot,k);
                    handles.Figure(i).Axis(j).Plot(k).Name=txt{itxt+1};
            end
            if k>0
                handles=ReadPlotOptions(handles,txt,itxt,i,j,k,0,0);
            end

            end_dataset=or(strcmp(lower(txt{itxt}),'enddataset'),strcmp(lower(txt{itxt}),'endsubplot'));
            itxt=itxt+1;
            if strcmp(lower(txt{itxt-1}),'endsubplot')
                itxt=itxt-1;
            end
            handles.Figure(i).Axis(j).Nr=k;
        end
        if strcmp(lower(txt{itxt}),'endsubplot')
            end_datasets=1;
            itxt=itxt+1;
        end

        stopstr={'endfigure','outputfile','annotations'};

        end_subplots=max(strcmp(lower(txt{itxt}),stopstr));

    end
    
    if SessionVersion<3.05
        handles.Figure(i).Axis(j).VectorLegendPosition(1)=handles.Figure(i).Axis(j).VectorLegendPosition(1)+handles.Figure(i).Axis(j).Position(1);
        handles.Figure(i).Axis(j).VectorLegendPosition(2)=handles.Figure(i).Axis(j).VectorLegendPosition(2)+handles.Figure(i).Axis(j).Position(2);
        handles.Figure(i).Axis(j).NorthArrow(1)=handles.Figure(i).Axis(j).NorthArrow(1)+handles.Figure(i).Axis(j).Position(1)-0.5*handles.Figure(i).Axis(j).NorthArrow(3);
        handles.Figure(i).Axis(j).NorthArrow(2)=handles.Figure(i).Axis(j).NorthArrow(2)+handles.Figure(i).Axis(j).Position(2)-0.5*handles.Figure(i).Axis(j).NorthArrow(3);
        handles.Figure(i).Axis(j).ScaleBar(1)=handles.Figure(i).Axis(j).ScaleBar(1)+handles.Figure(i).Axis(j).Position(1);
        handles.Figure(i).Axis(j).ScaleBar(2)=handles.Figure(i).Axis(j).ScaleBar(2)+handles.Figure(i).Axis(j).Position(2);
    end

end

