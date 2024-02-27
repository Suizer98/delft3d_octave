function [ana res] = triana_runTidalAnalysis(runID,hdt,hdz,ana_info)

% This function performs a tidal analysis using the Delft3D-Tide executable

ana = [];
res = [];

if ~isfield(ana_info,'fourier')
    ana_info.fourier = 1;    
end

sourceText='';
timeRange=[ana_info.timeStart ana_info.timeEnd]; %specify range in datenum (start & end) or leave empty for all data in time series: timeRange=[]
gapFill='interp';
interpMethod='cubic';

Subperiods{1} = [ana_info.timeStart ana_info.timeEnd];
hddt=ana_info.new_interval/(24*60); %Time interval, if not set, it will be attempted to compute

maxGap=45; %in days
minDur=14; %in days
maxDur=366; %in days
freqTxtFraction=.4; %fraction of maximum residual bin after fourier to plot frequency text at peaks

% find location of mat file containing an overview of all tidal constiuents
% in Delft3D-TIDE
DirCmpDTide = which('Frequency_Tidal_Components.mat');

%% processing
%Split timeseries
%1. use timeRange
if ~isempty(timeRange)
    timeRange=sort(timeRange);
    id=find(hdt>=timeRange(1)&hdt<=timeRange(2));
    hdt=hdt(id);
    hdz=hdz(id);
end

%2. split series (cut on time jumps and defaults (=nan)
id=find(isnan(hdz));
hdt(id)=[];
hdz(id)=[];
dayt=diff(hdt);
id=[0 ; find(dayt>maxGap)' ;length(hdt)];

sset={};
for ii=1:length(id)-1
    setLen=abs(diff([hdt(id(ii)+1) hdt(id(ii+1))]));
    if setLen<minDur
        %Do not add to set
        %         disp('skipped');
        continue
    elseif setLen>maxDur
        if isempty(hddt)
            hddt=abs(diff(hdt([hdt(id(ii)+1) hdt(id(ii)+2)])));
        end
        
        %Special treatment, split in maxDur periods
        for uu=1:floor(setLen/maxDur)
            sset=[sset {id(ii)+1+(uu-1)*maxDur/hddt:id(ii)+(uu)*maxDur/hddt}];
        end
        sset=[sset {id(ii)+1+(uu)*maxDur/hddt:id(ii+1)}];
        %         disp('split');
        
    else
        sset=[sset {id(ii)+1:id(ii+1)}];
        %         disp('added')
    end
end

%Remove empty sset's
idEmpty=find(cellfun('isempty',sset));
sset(idEmpty)=[];

save sset.mat sset

if length(sset) == 0
   disp('Warning: The selected period did not match the criteria: minimum duration: 30 days, maximum gap: 45 days, maximum duration: 365 days') 
end

for ii=1:length(sset)
    
    clear tz tt
    
    tStr=strrep(datestr(hdt(sset{ii}(1)),30),'T','_');
    eStr=strrep(datestr(hdt(sset{ii}(end)),30),'T','_');
    
    Subperiods{1} = [hdt(sset{ii}(1)) hdt(sset{ii}(end))]; 

    %OBS
    fid=fopen([runID tStr '.obs'],'w');
    fprintf(fid,['+ ' sourceText '\n']);
    fprintf(fid,['+ ' tStr ' - ' eStr '\n']);
    fprintf(fid,'+ dummy\n');
    fprintf(fid,'+ dummy\n');
    fprintf(fid,'+ dummy\n');
    
    if isempty(hddt)
        hddt=abs(diff(hdt(sset{ii}(1:2))));
    end
    epst=datenum(0,0,0,0,0,1);
    tt=[hdt(sset{ii}(1)):round(hddt/epst)*epst:hdt(sset{ii}(end))]';                    %Time with 5 min interval
    tt=round(tt/epst)*epst;
    tz=repmat(nan,length(tt),1);
    id=find(ismember(tt,round(hdt(sset{ii})/epst)*epst));
    tz(id)=hdz(sset{ii});                                                               %WL at 5 min interval
    
    %Treat gaps
    switch lower(gapFill)
        case 'mean'
            tz(isnan(tz))=mean(tz(~isnan(tz)));
        case '999'
            tz(isnan(tz))=999;
        case 'interp'
            if ~exist('interpMethod')|isempty(interpMethod)
                interpMethod='linear';
            end
            tz=interp1(tt(~isnan(tz)),tz(~isnan(tz)),tt,interpMethod);
        case 'hindcast'
            
            if ~exist('hindcastFile','var')|isempty(hindcastFile)|~exist([fileparts(hindcastFile) filesep runID tStr '.tka'],'file')
                warning(['Hindcast file: ' fileparts(hindcastFile) filesep runID tStr '.tka' ' for filling gaps not found...filling with mean value']);
                tz(isnan(tz))=mean(tz(~isnan(tz)));
            else
                %Save old cmp file
                movefile([fileparts(hindcastFile) filesep runID tStr '.cmp'],[fileparts(hindcastFile) filesep runID tStr '.cmp' num2str(round(rand(1)*1000),'%4.4i')]);
                tkaData=TIDE_readTKA([fileparts(hindcastFile) filesep runID tStr '.tka']);
                tkaDatenum=tekaltime2datenum(tkaData(:,1),tkaData(:,2));
                
                idNan=find(isnan(tz));
                for nn=1:length(idNan)
                    tz(idNan(nn))=tkaData(abs(tkaDatenum-tt(idNan(nn)))<epst,3);
                end
            end
    end
    
    
    fprintf(fid,'%f\n',tz');
    fclose(fid);                                                                %Closing .obs file
    
    
    %INA
    %% added by W. Verbruggen
    for mm = 1:length(Subperiods)
        ID_start = find(abs(hdt-Subperiods{mm}(1)) == min(abs(abs(hdt-Subperiods{mm}(1)))));
        ID_end = find(abs(hdt-Subperiods{mm}(2)) == min(abs(abs(hdt-Subperiods{mm}(2)))));
        
        eStr_subset=strrep(datestr(hdt(sset{ii}(ID_end)),30),'T','_');
        
        if mm >1
            if Subperiods{mm}(1) == Subperiods{mm-1}(2)
                tStr_subset=strrep(datestr(hdt(sset{ii}(ID_start+1)),30),'T','_');
            else
                tStr_subset=strrep(datestr(hdt(sset{ii}(ID_start)),30),'T','_');
            end
        else
            tStr_subset=strrep(datestr(hdt(sset{ii}(ID_start)),30),'T','_');
        end
        %subsets_txt = [subsets_txt;strrep(tStr_subset(3:end),'_','  ');strrep(eStr_subset(3:end),'_','  ')];
        subsets_txt{mm*2-1,1} = strrep(tStr_subset(3:end),'_','  ');
        subsets_txt{mm*2,1} = strrep(eStr_subset(3:end),'_','  ');
    end
    
    %%
    ina=textread('analyse.ina.template','%s','delimiter','\n');
    ina=regexprep(ina,'%NOBS%',num2str(length(tz)));
    ina=regexprep(ina,'%STARTYEAR%',strrep(tStr(3:end),'_','  '));
    ina=regexprep(ina,'%ENDYEAR%',strrep(eStr(3:end),'_','  '));
    ina=regexprep(ina,'%NOSS%',num2str(length(Subperiods)));
    
    ina_dummy = ina;
    for nn = 1:length(ina)
        if strcmp(ina{nn},'%TIMESSUBPERIODS%')
            ID_subsets = nn;
        end
    end
    ina(ID_subsets:ID_subsets+length(subsets_txt)-1) = subsets_txt;
    ina(ID_subsets+length(subsets_txt)) = ina_dummy(ID_subsets+1);
    
    fid=fopen([runID tStr '.ina'],'w');
    for uu=1:length(ina)
        fprintf(fid,'%s\n',ina{uu});
    end
    fclose(fid);
    
    %tide_inp
    ina=textread('tide_inp.ana.template','%s','delimiter','\n');
    ina=regexprep(ina,'%FILES%',[runID tStr]);
    fid=fopen(['tide_inp'],'w');
    for uu=1:length(ina)
        fprintf(fid,'%s\n',ina{uu});
    end
    fclose(fid);
    
    %Analyse
    %system(['ANALYSIS.exe'])
    
    system(['tide_analysis.exe']);
    
    %% Fourier analysis
    
    load(DirCmpDTide);
    
    d=TIDE_readTKA([runID tStr '.tka']);
    t=tekalTime2datenum(d(:,1),d(:,2));
     
    res.time = t;
    res.val = d(:,5); 
    if ana_info.fourier == 1
        
        figTS=figure;
        hold on
        
        
        measured = d(:,4)-mean(d(:,4));
        hP(1) = plot(t,measured,'k','DisplayName','measured');
        hP(2) = plot(t,d(:,3)-mean(d(:,3)),'b','DisplayName','analysed');
        hP(3) = plot(t,d(:,5)-mean(d(:,5)),'g','DisplayName','residual');
        hL = legend(hP);
        title(tStr);
        set(gca,'XLim',[t(1) t(end)])
        %legend('Observation','Hindcast','Residual');
        datetick('x','keeplimits');
        grid on
        print(gcf,'-dpng','-r300',[runID tStr '.png']);
        %saveas(gcf,[runID tStr '.fig'], 'fig');
        
        %Fourier
        fourF=[354 708 4248 8496]/(hddt*24);
        dists=length(d(:,5))-fourF;
        dists(dists<0)=[];
        [dum,mid]=min(dists);
        
        if ~isempty(mid)
            fL=fourF(mid);
            r=fft(d(1:fourF(mid),5),fL);
            %r=r.*conj(r)/fL;
            r=2*abs(r)/fL;
            r=r(1:fL/2+1);
            f=360*[0:fL/2]/fL/(hddt*24); %*rad2deg(2*pi/size(d,1))/(hddt*24);
            
            figF=figure;
            subplot(2,1,1)
            plot(f,r);
            xlim([0 360]);
            xlabel('Angular frequency [degr/hour]')
            ylabel('Amplitude')
            id=find(r>max(r)*freqTxtFraction);
            grid on
            for ff=1:length(id)
                text(f(id(ff)),r(id(ff)),num2str(f(id(ff))));
            end
            title(tStr);
            legend('Fourier of residual');
            
            
            subplot(2,1,2)
            plot(f,r);
            xlim([0 30]);
            xlabel('Angular frequency [degr/hour]')
            ylabel('Amplitude')
            id=find(r>max(r)*freqTxtFraction);
            grid on
            for ff=1:length(id)
                text(f(id(ff)),r(id(ff)),num2str(f(id(ff))));
            end
            title(tStr);
            legend('Fourier of residual');
            
            print(gcf,'-dpng','-r300',[runID 'fourier_' tStr '.png']);
            
            %% write file with missing components according to fourier analysis
            missing_freq = f(id)';
            miss_freq_amp = r(id);
            [miss_freq_amp IDsort] = sort(miss_freq_amp,'descend');
            missing_freq = missing_freq(IDsort);
            
            IDNearest = nearestpoint(missing_freq,cmp_all.freq);
            
            %% writing .bca file
            fid=fopen([runID tStr '_missing_cmp.txt'],'w');
            fprintf(fid,'%s \n','*** column1: missing frequency','*** column 2: amplitude from fourier analysis','*** column 3: corresponding component','*** column 4: real frequency corresponding component',...
                '*** column 5,6: previous component','*** column 7,8: next component');
            for cc = 1:length(missing_freq)
                fprintf(fid,'%9.4f %9.4f %-10s %9.4f %-10s %9.4f %-10s %9.4f \n',missing_freq(cc),miss_freq_amp(cc),cmp_all.cmp{IDNearest(cc)},cmp_all.freq(IDNearest(cc)),cmp_all.cmp{max(IDNearest(cc)-1,1)},cmp_all.freq(max(IDNearest(cc)-1,1)),cmp_all.cmp{min(IDNearest(cc)+1,length(cmp_all.cmp))},cmp_all.freq(min(IDNearest(cc)+1,length(cmp_all.cmp))));        
            end
            fclose(fid);
            
            
        else
            warning('Series too short for Fourier analysis...');
        end
        
        %Build results structure
        ana(ii).times=hdt(sset{ii});
        ana(ii).data=hdz(sset{ii});
        ana(ii).source=sourceText;
        
        ana(ii).res=d(:,5);
        
    end
    
    %% Read CMP
    fid=fopen([runID tStr '.cmp']);
    lin=fgetl(fid);
    while ~strncmp(lin,'NUMBER OF COMPONENTS',20)|feof(fid)
        lin=fgetl(fid);
    end
    [dum,lin]=strtok(lin,':');
    ncmp=str2num(lin(2:end));
    %3 dummies
    for dd=1:3
        fgetl(fid);
    end
    for cc=1:ncmp
        lin=fgetl(fid);
        vars = strsplit(lin,' ');
        ana(ii).cmp{cc,1} = vars{1};
%         [ana(ii).cmp(cc,1),A,G,dum,dum,dum]=strread(lin,repmat('%s',1,6));
%         A=A{1};
%         G=G{1};
        if isempty(str2num(vars{2}))
            ana(ii).A(cc,1)=NaN;
        else
            ana(ii).A(cc,1)=str2num(vars{2});
        end
        if isempty(str2num(vars{3}))
            ana(ii).G(cc,1)=NaN;
        else
            ana(ii).G(cc,1)=str2num(vars{3});
        end

        if isempty(str2num(vars{4}))
            ana(ii).freq(cc,1)=NaN;
        else
            ana(ii).freq(cc,1)=str2num(vars{4});
        end
        
    end
    %1 dummy
    fgetl(fid);
    %SD
    lin=fgetl(fid);
    [dum,lin]=strtok(lin,':');
    ana(ii).std=str2num(lin(2:end));
    
    fclose(fid);
    close all
    
end