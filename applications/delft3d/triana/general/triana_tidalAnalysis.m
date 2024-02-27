function s = triana_tidalAnalysis(s);

% check if outputdir already exists
mkdir(s.outputDir);

% copy template files and tide_analysis executable to outputDir
dirFiles = [fileparts(which('triana')),filesep,'toBeCopiedFiles'];
copyfile([dirFiles,filesep,'tide_inp.ana.template'],s.outputDir);
copyfile([dirFiles,filesep,'irpana21.dat'],s.outputDir);
if ~exist(s.ana.exe,'file')
    s.ana.exe = [dirFiles,filesep,'tide_analysis.exe'];
end
copyfile(s.ana.exe,s.outputDir);


% check if a ina.template has been specified
if isfield(s.ana,'inputFile')
    copyfile(s.ana.inputFile,s.outputDir);
else
    % set consituents
    ina=textread([dirFiles,filesep,'no_constituents_analyse.ina.template'],'%s','delimiter','\n');
    ina=regexprep(ina,'%NUMCONST%',num2str(length(s.ana.constituents)));
    ID_const = find(~cellfun('isempty',regexp(ina,'%CONSTITUENTS%')));
    ina = [ina(1:ID_const-1);s.ana.constituents';ina(ID_const+1:end)];
    
    fid=fopen([s.outputDir,filesep,'analyse.ina.template'],'w');
    for uu=1:length(ina)
        fprintf(fid,'%s\n',ina{uu});
    end
    fclose(fid);
end

% go to s.outputDir
cd(s.outputDir)

% extract timeseries per station and perform analysis
for ss = 1:length(s.modID)
    runID = strrep([deblank(s.model.data.stats{ss}),'_',s.description,'_'],'/',' ');
    
    disp(['Processing station ',num2str(ss),' of ',num2str(length(s.modID)),': ',deblank(s.model.data.stats{ss})]);
    
    % construct timeseries (time and water level)
    IDTime = find(s.model.data.Time>=s.ana.timeStart & s.model.data.Time<=s.ana.timeEnd);
    s.ana.timeEnd = s.model.data.Time(IDTime(end));
    
    s.ana.timeStart = max(s.model.data.Time(IDTime(1)),s.ana.timeEnd-365); % maximum number of days in anylsis is 365 
    
    
    hdt = round(s.ana.timeStart*(24*60/s.ana.new_interval))/(24*60/s.ana.new_interval):s.ana.new_interval/1440:round(s.ana.timeEnd*(24*60/s.ana.new_interval))/(24*60/s.ana.new_interval);
    hdz = interp1(s.model.data.Time,s.model.data.WL(ss,:),hdt);
    
    % take into account time zone of model
    hdt = hdt-s.model.timeZone/24;
    
    if sum(isnan(hdz))/length(hdz)<0.05
        ana = triana_runTidalAnalysis(runID,hdt,hdz,s.ana);
    end
    
    s.triana.Acomp(:,ss) = ana.A;
    s.triana.Gcomp(:,ss) = ana.G;
    s.triana.Cmp = ana.cmp;
    s.triana.Freq = ana.freq;
    
    s.triana.Gobs(:,ss) = zeros(length(s.triana.Cmp),1)+NaN;
    s.triana.Aobs(:,ss) = zeros(length(s.triana.Cmp),1)+NaN;
    if ~isnan(s.measID(ss))
        s.triana.statsObs{ss} = s.meas.data(s.measID(ss)).name;
        for cc = 1:length(ana.cmp)
            for cc2 = 1:length(s.meas.data(s.measID(ss)).Cmp)
                if strcmpi(s.meas.data(s.measID(ss)).Cmp{cc2},ana.cmp{cc})
                    s.triana.Aobs(cc,ss) = s.meas.data(s.measID(ss)).A(cc2);
                    s.triana.Gobs(cc,ss) = s.meas.data(s.measID(ss)).G(cc2);
                end
            end
        end
    else
        s.triana.statsObs{ss} = NaN;
    end
end

% move files to "Analysis" folder
makedir([pwd '\Analysis']);
try
    movefile(['*',datestr(s.ana.timeStart,'yyyymmdd'),'*'],[pwd '/Analysis/'])
end

s.triana.X = s.model.data.X;
s.triana.Y = s.model.data.Y;
s.triana.statsComp = s.model.data.stats;