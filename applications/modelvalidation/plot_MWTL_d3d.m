% .mat file comes from netcdf2mon.m


clear all;
close all;
clc;

%% Reading his data files and .mat file

%% his file
waqDir = 'd:\GEM-Egmond\resultaten\run009\'; %location of his files
autScenario = 'egm09';% name of the hisfile
indStations = 0;

%for his files from ksenos (year is the year 1900)
year_his=datenum('01-01-1900','dd-mm-yyyy');
real_year=datenum('01-01-2009','dd-mm-yyyy');
correction=real_year-year_his; %used at line 125

autHisStruct = delwaq('open', [waqDir autScenario '.his']); %name of the hisfile when it is read by matlab
indSubs = find(strcmpi(autHisStruct.SubsName, 'Sal'));  %selection of substance
indTime = 1:autHisStruct.NTimes;

[autTime, autData] = delwaq('read', autHisStruct, indSubs, indStations, indTime); % reading time and data of hisfile

%% mat.file (measurements)

load 'd:\GEM-Egmond\Sal.mat'

Stations=fieldnames(Data);

for i=1:length(Stations)
    
    mask=(Data.(Stations{i}).datenum)>=datenum(2009,1,1)& (Data.(Stations{i}).datenum)<=datenum(2010,12,31); %select your period here
    new_datestr=Data.(Stations{i}).datenum(mask);
    if ~isempty(new_datestr)
        for dd=1:length(new_datestr)
            D.(Stations{i}).time(dd,:)=new_datestr(dd);
            D.(Stations{i}).data=Data.(Stations{i}).sea_water_salinity(mask);
        end
        continue
    end
    
end

Location_old=fieldnames(D); %determine the amount of stations which have data for the selected period

% TODO: make function of converting names.

% as the names used in waterbase deviate from the names used in
% Egmond-project, the names should be conversed from waterbase to Egmond
% names....need to be extended when more measurement locations have
% data (so, when other substance is used or other time period...is easy to
% check when looking into 'Location_old' (suggestion make
% excel file to keep track on changes in measurement location for easy
% comparison...and by doing that, elaborate script beneath).

for i=1:length (Location_old);
    if strcmp(Location_old{i},'blauwsot')
        Location_new{i}='WZ230Blauwe(1)';
    elseif strcmp(Location_old{i},'dantzgt')
        Location_new{i}='WZ420Dantzig(1)';
    elseif strcmp(Location_old{i},'doovbot')
        Location_new{i}='WZ200DooveB(1)';
    elseif strcmp(Location_old{i},'doovbwt')
        Location_new{i}='WZ110DooveB(1)';
    elseif strcmp(Location_old{i},'goere2')
        Location_new{i}='NZR4GR002(1)';
    elseif strcmp(Location_old{i},'goere6')
        Location_new{i}='NZR4GR006(1)';
    elseif strcmp(Location_old{i},'ijmdn1')
        Location_new{i}='IJmuid001(1)';
    elseif strcmp(Location_old{i},'marsdnd')
        Location_new{i}='WZ30Marsdie(1)';
    elseif strcmp(Location_old{i},'noordwk2')
        Location_new{i}='NZR6NW002(1)';
    elseif strcmp(Location_old{i},'noordwk10')
        Location_new{i}='NZR6NW010(1)';
    elseif strcmp(Location_old{i},'noordwk20')
        Location_new{i}='NZR6NW020(1)';
    elseif strcmp(Location_old{i},'noordwk70')
        Location_new{i}='NZR6NW070(1)';
    elseif strcmp(Location_old{i},'rottmpt3')
        Location_new{i}='Rottum3(1)';
    elseif strcmp(Location_old{i},'rottmpt50')
        Location_new{i}='Rottum50';
    elseif strcmp(Location_old{i},'rottmpt70')
        Location_new{i}='Rottum70(1)';
    elseif strcmp(Location_old{i},'schouwn10')
        Location_new{i}='NZR3SW010(1)';
    elseif strcmp(Location_old{i},'terslg10')
        Location_new{i}='NZR9TS010(1)';
    elseif strcmp(Location_old{i},'terslg50')
        Location_new{i}='NZR9TS050(1)';
    elseif strcmp(Location_old{i},'terslg100')
        Location_new{i}='NZR9TS100(1)';
    elseif strcmp(Location_old{i},'terslg135')
        Location_new{i}='NZR9TS135(1)';
    elseif strcmp(Location_old{i},'terslg175')
        Location_new{i}='NZR9TS175(1)';
    elseif strcmp(Location_old{i},'terslg235')
        Location_new{i}='NZR9TS235(1)';
    elseif strcmp(Location_old{i},'vliesm')
        Location_new{i}='WZ190Vliestr(1)';
    elseif strcmp(Location_old{i},'walcrn2')
        Location_new{i}='NZR2WC002(1)';
    elseif strcmp(Location_old{i},'walcrn20')
        Location_new{i}='NZR2WC020(1)';
    elseif strcmp(Location_old{i},'walcrn70')
        Location_new{i}='NZR2WC070(1)';
    elseif strcmp(Location_old{i},'zoutkplzgt')
        Location_new{i}='zoutkplzg(1)';
    end
end

%% filter his file on stations that do have waterbase data for selected period

for j=1:length(autHisStruct.SegmentName)
    for k=1:length (Location_new)
        if strcmpi(Location_new{k},autHisStruct.SegmentName{j})
            Location_1=strrep(Location_new{k},' ','');
            Location_2=strrep(Location_1,'(','');
            Location=strrep(Location_2,')','');
            H.(Location).data=squeeze(autData(:,j,:));
            H.(Location).time=correction + autTime;
        end
    end
end

% again: due to hard coding and difference of names, name conversion
% needed, in this case from egmond-names to waterbase-names....update list
% when more waterbasestations have data (so, when another time period or
% substance is used)

[H.walcrn2]=H.NZR2WC0021;
[H.walcrn70]=H.NZR2WC0701;
[H.schouwn10]=H.NZR3SW0101;
[H.goere6]=H.NZR4GR0061;
[H.noordwk2]=H.NZR6NW0021;
[H.noordwk10]=H.NZR6NW0101;
[H.noordwk20]=H.NZR6NW0201;
[H.noordwk70]=H.NZR6NW0701;
[H.terslg10]=H.NZR9TS0101;
[H.terslg50]=H.NZR9TS0501;
[H.doovbwt]=H.WZ110DooveB1;
%[H.doovbot]=H.WZ200DooveB1;
[H.vliesm]=H.WZ190Vliestr1;
[H.blauwsot]=H.WZ230Blauwe1;
[H.dantzgt]=H.WZ420Dantzig1;
[H.zoutkplzgt]=H.zoutkplzg1;
[H.terslg100]=H.NZR9TS1001;
[H.terslg135]=H.NZR9TS1351;
[H.terslg175]=H.NZR9TS1751;
[H.terslg235]=H.NZR9TS2351;
[H.rottmpt3]=H.Rottum31;
[H.rottmpt70]=H.Rottum701;

loc_model=fieldnames(H);

%% Plotting data


for j=1:length(Location_old)
    
    for k=1:length(loc_model)
        if strcmpi(Location_old{j},loc_model{k})
            
            figure(j);
            hold on;grid on;
            
            figure (j);
            plot (H.(loc_model{k}).time,H.(loc_model{k}).data, 'r-')
            hold on
            plot (D.(Location_old{j}).time,D.(Location_old{j}).data, 'ko')
            
            title(Location_old {j});
            ylabel('Saliniteit');
            xlim([datenum(2008,12,31) datenum(2011,1,1)]);
            datetick('x','mmmyy','keepticks')
            
            print(['MWTL_sal_compare_' Location_old{j} '.png'], '-dpng');
            close
        end
    end
end

%% OEF

