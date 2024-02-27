function s = triana_tidalAnalysis_t_tide(s);

% check if outputdir already exists
mkdir(s.outputDir);
mkdir([s.outputDir,filesep,'Analysis_t_tide']);

[lon lat] = convertCoordinates(s.model.data.X,s.model.data.Y,'CS1.code',s.model.epsg,'CS2.code',4326);

% extract timeseries per station and perform analysis
for ss = 1:length(s.modID)
    disp(['Processing station ',num2str(ss),' of ',num2str(length(s.modID)),': ',deblank(s.model.data.stats{ss})]);
    
    IDTime = find(s.model.data.Time>=s.ana.timeStart & s.model.data.Time<=s.ana.timeEnd);
    filenameDiag = [s.outputDir,filesep,'Analysis_t_tide',filesep,deblank(s.model.data.stats{ss}),'_analysis_overview.txt'];
%     [S,WL_pred] = t_tide(s.model.data.WL(ss,IDTime),'lat',lat(ss),'sort','->amp','interval',diff(s.model.data.Time(1:2))*24,'start',s.model.data.Time(IDTime(1))-s.model.timeZone/24,'err','lin','output',filenameDiag,'rayleigh',s.ana.constituents);
    [S,WL_pred] = t_tide(s.model.data.WL(ss,IDTime),'lat',lat(ss),'interval',diff(s.model.data.Time(1:2))*24,'start',s.model.data.Time(IDTime(1))-s.model.timeZone/24,'err','lin','output',filenameDiag,'rayleigh',s.ana.constituents);
    
    s.triana.Acomp(:,ss) = S.tidecon(:,1);
    s.triana.Gcomp(:,ss) = S.tidecon(:,3);
    s.triana.Cmp = char2cell(S.name);
    s.triana.Freq = S.freq*360;
    
    %% Plot residual water level
    meanWL = mean(s.model.data.WL(ss,IDTime));
    
    figure;
    hold on
    hP(1) = plot(s.model.data.Time(IDTime),s.model.data.WL(ss,IDTime)-meanWL,'k','DisplayName','measured');
    hP(2) = plot(s.model.data.Time(IDTime),WL_pred,'b','DisplayName','analysed');
    hP(3) = plot(s.model.data.Time(IDTime),s.model.data.WL(ss,IDTime)-WL_pred-meanWL,'g','DisplayName','residual');
    hL = legend(hP);
    title([deblank(s.model.data.stats{ss})]);
    set(gca,'XLim',[s.model.data.Time(IDTime(1)) s.model.data.Time(IDTime(end))])
    datetick('keeplimits');
    xlabel('Time [GMT]')
    ylabel('Water level [m]')
    grid on
    print(gcf,'-dpng','-r300',[s.outputDir,filesep,'Analysis_t_tide',filesep,deblank(s.model.data.stats{ss}),'_residual_signal.png']);
    close all
    
    
end

% fill triana structure for measurements
s = triana_perform_triana_for_measurements(s);
