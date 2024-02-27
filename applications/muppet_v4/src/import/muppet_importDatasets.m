function [handles,ok]=muppet_importDatasets(handles)

ok=0;

for id=1:handles.nrdatasets
    if strcmpi(handles.datasets(id).dataset.filetype,'combineddataset')
        handles.datasets(id).dataset.combineddataset=1;
    end
    dataset=handles.datasets(id).dataset;
    name=dataset.name;
    if ~dataset.combineddataset
        try
            % Find import routine
            ift=muppet_findIndex(handles.filetype,'filetype','name',dataset.filetype);
            dataset.callback=str2func(handles.filetype(ift).filetype.callback);
            % Get file info
            dataset=feval(dataset.callback,'read',dataset);
            if isfield(dataset,'parameters')
                % Multiple parameters available, copy appropriate data from parameters structure to
                % dataset structure
                if isempty(dataset.parameter)
                    ii=1;
                else
                    ii=muppet_findIndex(dataset.parameters,'parameter','name',dataset.parameter);
                end
                fldnames=fieldnames(dataset.parameters(ii).parameter);
                for j=1:length(fldnames)
                    switch fldnames{j}
                        case{'name'}
                        otherwise
                            dataset.(fldnames{j})=dataset.parameters(ii).parameter.(fldnames{j});
                    end
                end
                dataset=rmfield(dataset,'parameters');
            end
            % Import
            dataset=feval(dataset.callback,'import',dataset);
            dataset.name=name;
        catch
            ok=0;
            muppet_giveWarning('text',['Could not load dataset ' dataset.name ' !']);
            return
        end
        handles.datasets(id).dataset=dataset;
    end
end

% Combine
for id=1:handles.nrdatasets
    if handles.datasets(id).dataset.combineddataset
        handles.datasets=muppet_combineDataset(handles.datasets,id);
    end
end

% Find types of datasets in subplots
for ifig=1:handles.nrfigures
    for isub=1:handles.figures(ifig).figure.nrsubplots
        if ~strcmpi(handles.figures(ifig).figure.subplots(isub).subplot.type,'annotation')
            for id=1:handles.figures(ifig).figure.subplots(isub).subplot.nrdatasets
                if strcmpi(handles.figures(ifig).figure.subplots(isub).subplot.datasets(id).dataset.plotroutine,'interactive polyline')
                    handles.figures(ifig).figure.subplots(isub).subplot.datasets(id).dataset.type='interactivepolyline';
                elseif strcmpi(handles.figures(ifig).figure.subplots(isub).subplot.datasets(id).dataset.plotroutine,'interactive text')
                    handles.figures(ifig).figure.subplots(isub).subplot.datasets(id).dataset.type='interactivetext';
                else
                    nr=muppet_findIndex(handles.datasets,'dataset','name',handles.figures(ifig).figure.subplots(isub).subplot.datasets(id).dataset.name);
                    if ~isempty(nr)
                        handles.figures(ifig).figure.subplots(isub).subplot.datasets(id).dataset.type=handles.datasets(nr).dataset.type;
                    else
                        ok=0;
                        muppet_giveWarning('text',['Dataset ' handles.figures(ifig).figure.subplots(isub).subplot.datasets(id).dataset.name ' not found!']);
                        return
                    end
                end
            end
        end
    end
end

ok=1;
