function optiGUI_exportData(type);

[but,fig]=gcbo;

this=get(fig,'userdata');
sliderValue=round(get(findobj(fig,'tag','conditionSlider'),'value'));
nodg=length(this.input);

switch type
    case 'QP'
        d3d_qp;
        for dg=1:nodg
            if strcmp(this.input(dg).dataType,'transport')&~isempty(this.input(dg).dataTransect)
                h=warndlg('Transports through transects cannot be plotted with QuickPlot, use Muppet!');
                uiwait(h);
            else
                data=optiGUI_getGriddedData(this,[],dg);
                if ~isempty(data.XComp)
                    data=rmfield(data,'Val');
                end
                save(['target_datagroup' num2str(dg) '.mat'],'data');
                data=optiGUI_getGriddedData(this,sliderValue,dg);
                if ~isempty(data.XComp)
                    data=rmfield(data,'Val');
                end
                save(['optimized_datagroup' num2str(dg) '.mat'],'data');
                d3d_qp('openfile',['target_datagroup' num2str(dg) '.mat']);
                d3d_qp('openfile',['optimized_datagroup' num2str(dg) '.mat']);
            end
        end
    case 'Muppet'
        for dg=1:nodg
            if strcmp(this.input(dg).dataType,'transport')&~isempty(this.input(dg).dataTransect)
                [namL,patL]=uiputfile('*.int','Save transports of reduced climate to');                
                [namL2,patL2]=uiputfile('*.int','Save transports of full climate to');
                data=this.input.data*this.iteration(length(this.iteration)+1-sliderValue).weights';
                target=this.input(dg).target;
                if strcmp(this.input.transportMode,'gross')
                    % bewerking uitvoeren zodat nett er bij staat (ofwel 3
                    % transporten per transect) en deze wegschrijven naar
                    % aparte lint files (per gross component)
                    data=reshape(data,[length(data)/2 2]);
                    data=[sum(data,2) data];
                    target=reshape(target,[length(target)/2 2]);
                    target=[sum(target,2) target];
                    tekal('write',fillExtension([patL filesep 'grossComponent1_' namL],'int'),[[1:length(data)]' data(:,1)]);
                    tekal('write',fillExtension([patL2 filesep 'grossComponent1_' namL2],'int'),[[1:length(data)]' target(:,1)]);
                    tekal('write',fillExtension([patL filesep 'grossComponent2_' namL],'int'),[[1:length(data)]' data(:,1)]);
                    tekal('write',fillExtension([patL2 filesep 'grossComponent2_' namL2],'int'),[[1:length(data)]' target(:,1)]);
                    namL=['nett_' namL];
                    namL2=['nett_' namL2];                    
                end               
                tekal('write',fillExtension([patL filesep namL],'int'),[[1:length(data)]' data(:,1)]);
                tekal('write',fillExtension([patL2 filesep namL2],'int'),[[1:length(data)]' target(:,1)]);
            else
                h=warndlg('Not yet implemented for sedero or transport map-fields, use QuickPlot!');
                uiwait(h);
            end
        end
end