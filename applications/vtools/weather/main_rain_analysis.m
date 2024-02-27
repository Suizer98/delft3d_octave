% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18307 $
%$Date: 2022-08-18 11:53:26 +0800 (Thu, 18 Aug 2022) $
%$Author: chavarri $
%$Id: main_rain_analysis.m 18307 2022-08-18 03:53:26Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/weather/main_rain_analysis.m $
%

%% PREAMBLE

clear
clc
fclose all;

%% ADD OET

path_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
addpath(path_add_fcn)
addOET(path_add_fcn) %1=c-drive; 2=p-drive

%% INPUT

fdir_weather='p:\i1000561-riverlab-2021\04_weather\';

%% CALC

    %% load
fname_mod=fullfile(fdir_weather,'rain.mat');
fname_mea=fullfile(fdir_weather,'measured.csv'); %https://docs.google.com/spreadsheets/d/1NPFs3vNRbhV-pt_j2KBe_7bwGnvZG9aVZDksn4EB-80/edit?usp=sharing

load(fname_mod,'rain');

% mea_raw=readcell(fname_mea,'NumHeaderLines',1);
% mea_tim=datetime(mea_raw(:,1),'InputFormat','dd-MM-yyyy');
% mea_val=cell2mat(mea_raw(:,2));
% idx_d=find(mea_val==-999,1,'first');
% mea_tim=mea_tim(1:idx_d-1);
% mea_val=mea_val(1:idx_d-1);

mea_tim=datetime(2022,08,15,00,00,00);
mea_val=40.6;

    %% 
[mod_tim,idx_u]=unique([rain.tim_model]);
nmod=numel(mod_tim);

mod_val_m=[rain(idx_u).rain]';
mod_tim_rm=repmat(mod_tim',1,14);
mod_tim_m=mod_tim_rm+days(0:1:13).*ones(nmod,14);
mod_tim_m_d=dateshift(mod_tim_m,'start','day');


%%

nmea=numel(mea_tim);
mod_val_s=cell(nmea,1);
mod_tim_s=cell(nmea,1);
diff_tim=cell(nmea,1);
diff_val=cell(nmea,1);
for kmea=1:nmea
    mea_tim_loc=mea_tim(kmea);
    bol_sd=mod_tim_m_d==mea_tim_loc; 
    mod_val_loc=mod_val_m(bol_sd);
    mod_tim_loc=mod_tim_rm(bol_sd);
    
    [mod_tim_s{kmea,1},idx_s]=sort(mod_tim_loc);
    mod_val_s{kmea,1}=mod_val_loc(idx_s);
    
    diff_tim{kmea,1}=mod_tim_s{kmea,1}-mea_tim(kmea);
    diff_val{kmea,1}=mod_val_s{kmea,1}-mea_val(kmea);
    
    bolm24=diff_tim{kmea,1}>-hours(24);
    diff_tim{kmea,1}(bolm24)=[];
    diff_val{kmea,1}(bolm24)=[];
end %kmea

%%

figure
hold on
for kmea=1:nmea
    plot(diff_tim{kmea,1},diff_val{kmea,1},'*-k');
    
%     pause
end
ylabel('predicted daily rain - measured daily rain [mm]')
xtickformat(gca,'d')

%%

in_p.fig_print=1;
in_p.fig_visible=0;
in_p.fname='c:\Users\chavarri\Downloads\rain_01';

for kmea=1:nmea
    in_p.mod_tim=mod_tim_s{kmea,1};
    in_p.mod_val=mod_val_s{kmea,1};
    in_p.mea_tim=mea_tim(kmea);
    in_p.mea_val=mea_val(kmea);
    
    fig_rain_event_01(in_p);
end

