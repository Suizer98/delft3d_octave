function EHY_plotmodeldata
%% EHY_plotmodeldata
%
% Interactive retrieval and plotting of model data using EHY_getmodeldata
% Example: EHY_plotmodeldata
%
%%
% get data
Data = EHY_getmodeldata_interactive;

% plot data
if ndims(Data.val) == 3
    for iS = 1:size(Data.val,2) % loop over stations
        figure('units','normalized','position',[0.05 0.1 0.9 0.8])
        hold on
        grid on
        plot(Data.times,squeeze(Data.val(:,iS,:)))
        datetick('x','dd-mmm-yyyy','keeplimits','keepticks')
        try title(Data.requestedStations{iS}); end
    end
else
    figure('units','normalized','position',[0.05 0.1 0.9 0.8])
    hold on
    grid on
    plot(Data.times,Data.val)
    datetick('x','dd-mmm-yyyy','keeplimits','keepticks')
end