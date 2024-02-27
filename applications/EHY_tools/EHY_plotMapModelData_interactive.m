function EHY_plotMapModelData_interactive
%% EHY_plotMapModelData_interactive
%
% Interactive retrieval and plotting of model data using EHY_plotMapModelData
% Example: EHY_plotMapModelData_interactive
%
%%
% get data
[Data,gridInfo,OPT] = EHY_getMapModelData_interactive;

if isfield(Data,'times') && length(Data.times)>1
    option=listdlg('PromptString','Plot these time steps (as animation): (Use CTRL to select multiple time steps)','ListString',...
        datestr(Data.times),'ListSize',[400 400]);
    if isempty(option); disp('EHY_plotMapModelData_interactive was stopped by user');return; end
    plotInd = option;
elseif isfield(Data,'times') && length(Data.times)==1
    plotInd = 1;
else
    plotInd = [];
end

% facecolor ('flat' or 'interp'/'Continuous shades')
if isfield(OPT,'facecolor') && strcmp(OPT.facecolor,'interp')
    txt_facecolor = ',''facecolor'',''interp''';
else
    txt_facecolor = '';
end

% if velocity was selected
if isfield(Data,'vel_mag')
    disp(['<strong>EHY_plotMapModelData(gridInfo,Data.vel_mag(' num2str(plotInd(1)) repmat(',:',1,ndims(Data.vel_mag)-1) ')' txt_facecolor ');</strong>' ])
else
    if isempty(plotInd)
        disp(['<strong>EHY_plotMapModelData(gridInfo,Data.val'  txt_facecolor ');</strong>'])
    else
        if isfield(OPT,'pliFile') && ~isempty(OPT.pliFile) % data along xy-trajectory
            disp(['<strong>t = ' num2str(plotInd(1)) ';</strong>' ])
            disp(['<strong>EHY_plotMapModelData(gridInfo,Data.val(t' repmat(',:',1,ndims(Data.val)-1) '),''t'',t);</strong>' ])
        else
            disp(['<strong>EHY_plotMapModelData(gridInfo,Data.val(' num2str(plotInd(1)) repmat(',:',1,ndims(Data.val)-1) ')' txt_facecolor ');</strong>' ])
        end
    end
end

disp('start plotting the top-view data...')
figure
for iPI = 1:max([1 length(plotInd)])
    
    if ~isempty(plotInd)
        iT = plotInd(iPI);
        if length(plotInd)>1
            disp(['Plotting top-views: ' num2str(iPI) '/' num2str(length(plotInd))])
        end
        if isfield(Data,'vel_mag')
            values = Data.vel_mag(iT,:,:,:);
        else
            values = Data.val(iT,:,:,:);
        end
        if isfield(Data,'OPT') && isfield(Data.OPT,'pliFile') && ~isempty(Data.OPT.pliFile) % data along xy-trajectory
            EHY_plotMapModelData(gridInfo,values,'t',iT)
        else
            if isfield(OPT,'facecolor') && strcmp(OPT.facecolor,'interp')
                EHY_plotMapModelData(gridInfo,values,'facecolor','interp')
            else
                EHY_plotMapModelData(gridInfo,values)
            end
        end
        title(datestr(Data.times(plotInd(iPI)),'dd-mmm-yyyy HH:MM:SS'))
    else
        if isfield(OPT,'facecolor') && strcmp(OPT.facecolor,'interp')
            EHY_plotMapModelData(gridInfo,Data.val,'facecolor','interp')
        else
            EHY_plotMapModelData(gridInfo,Data.val)
        end
    end
    pause(1)
end
disp('Finished plotting the top-view data!')

