%% inlezen van modeldata voor GoFStats_v3.m
%TODO: automaticcally make maps per substance....now it should be done by
%hand

clear all;
close all;
clc;

%todo loop over substances

loaparent= 'd:\GEM-Egmond\meetdata\Gof_Files\modeldata\';
loadir='Model_Files';

req_sub={'NH4','Chlfa','Ext.tot','PO4','NO3',...
    'Sal','SI','IM1','TOTN','TOTP','OXY'};

year_start=2009;
year_end=2009;

year_his=datenum('01-01-1900','dd-mm-yyyy'); %if the modelled year isn't the same as the selected year...
real_year=datenum('01-01-2009','dd-mm-yyyy');
correction=real_year-year_his; %used at line 125

%% his file
waqDir = 'd:\GEM-Egmond\resultaten\run009\'; %location of his files
autScenario = 'egm09';% name of the hisfile
indStations = 0;

autHisStruct = delwaq('open', [waqDir autScenario '.his']); %name of the hisfile when it is read by matlab

for a=1:length(req_sub) %loop over substances
    
    indSubs = find(strcmpi(autHisStruct.SubsName, req_sub(a)));  %selection of substance
    indTime = 1:autHisStruct.NTimes;
    
    [autTime, autData] = delwaq('read', autHisStruct, indSubs, indStations, indTime); % reading time and data of hisfile
    
    for j=1:length(autHisStruct.SegmentName)
        version1=strrep(autHisStruct.SegmentName{j},'(','');
        version2=strrep(version1,'_','');
        version3=strrep(version2,'-','');
        Location=strrep(version3,')','');
        H.(Location).data=squeeze(autData(:,j,:));
        H.(Location).time=correction+autTime;
    end
    
    
    
    for i=1:length(H)
        [K.walcrn2]=H.NZR2WC0021;
        [K.walcrn70]=H.NZR2WC0701;
        [K.schouwn10]=H.NZR3SW0101;
        [K.goere6]=H.NZR4GR0061;
        [K.noordwk2]=H.NZR6NW0021;
        [K.noordwk10]=H.NZR6NW0101;
        [K.noordwk20]=H.NZR6NW0201;
        [K.noordwk70]=H.NZR6NW0701;
        [K.terslg10]=H.NZR9TS0101;
        [K.terslg50]=H.NZR9TS0501;
        [K.doovbwt]=H.WZ110DooveB1;
        [K.doovbot]=H.WZ200DooveB1;
        [K.vliesm]=H.WZ190Vliestr1;
        [K.blauwsot]=H.WZ230Blauwe1;
        [K.dantzgt]=H.WZ420Dantzig1;
        [K.zoutkplzgt]=H.Zoutkplzg1;
        [K.terslg100]=H.NZR9TS1001;
        [K.terslg135]=H.NZR9TS1351;
        [K.terslg175]=H.NZR9TS1751;
        [K.terslg235]=H.NZR9TS2351;
        [K.rottmpt3]=H.Rottum31;
        [K.rottmpt70]=H.Rottum701;
    end
    
    new_loc=fieldnames(K);
    
    cd(loaparent)
    if strcmpi(req_sub{a},'Ext.tot');
        mkdir('E')
        cd('E')
    elseif strcmpi(req_sub{a},'Chlfa');
        mkdir('concentration_of_chlorophyll_in_water')
        cd('concentration_of_chlorophyll_in_water')
    elseif strcmpi(req_sub{a},'IM1');
        mkdir('concentration_of_suspended_matter_in_water')
        cd('concentration_of_suspended_matter_in_water')
    elseif strcmpi(req_sub{a},'Sal');
        mkdir('sea_water_salinity')
        cd('sea_water_salinity')
    elseif strcmpi(req_sub{a},'TOTN');
        mkdir('N')
        cd('N')
    elseif strcmpi(req_sub{a},'TOTP');
        mkdir('P')
        cd('P')
    elseif strcmpi(req_sub{a},'SI');
        mkdir('SiO2')
        cd('SiO2')
    elseif strcmpi(req_sub{a},'OXY');
        mkdir('O2')
        cd('O2')
    else
        mkdir(req_sub{a});
        cd(req_sub{a})
    end
    
    
    
    for i=1:length(new_loc)
        if strcmpi (req_sub(a),'Ext.tot')
        filename = ['Ext','_',char(new_loc{i}),'_','model','.txt'];
        fid = fopen(filename,'w+');
        else filename = [char(req_sub(a)),'_',char(new_loc{i}),'_','model','.txt'];
        fid = fopen(filename,'w+');
        end
        
        for z=year_start:year_end
            
            mask=(K.(new_loc{i}).time)>=datenum(z,1,1)& (K.(new_loc{i}).time)<=datenum(z,12,31);
            new_datestr=K.(new_loc{i}).time(mask);
            
            for dd=1:length(new_datestr)
                K.(new_loc{i}).new_datestr(dd,:)=new_datestr(dd);
                xyear(dd)=datenum(year(new_datestr(dd)),1,1);
                K.(new_loc{i}).daynumber(dd,:)=ceil(new_datestr(dd)-xyear(dd));
                
                K.(new_loc{i}).stof_new=K.(new_loc{i}).data(mask);
                
            end
            
            
            for j=1:length(new_datestr)
                fprintf(fid,'%d\t%d \n',K.(new_loc{i}).daynumber(j,:),...
                    K.(new_loc{i}).stof_new(j));
            end
            
            
            clear ('mask')
        end
    end
    
    fclose ('all');
    
end

%% OEF