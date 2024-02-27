%netcdf2dis example to convert NetCDF data to dis files for Delft3D-Flow
%
%See also: waq, delwaq

%% NETCDF2DIS
%%% Author: Dr M. Chatelain (mathieu.chatelain@deltares.nl)
%%% Created: 28-nov-11

%%% Matlab code to convert NetCDF data to dis files for Delft3D-Flow
%%% The script needs to be run per YEAR

%%% 1) Choose the paths (1 PREPARATION>>PATHS)
%%% 2) Choose the year (1 PREPARATION >>OPTIONS)
%%% 3) Run the script (output=YEAR_flow.dis in the local dir)

%%% to do list:
%%% >> clean the code!
%%% >> hand association of rivers (discharge) and stations (temperature)
%%% >> loop over the years

clear all; hold off; close all; fclose all; warning off;


%% 1 PREPARATION
disp('preparation');
%%% paths
localdir='d:\matlab\'; %%% local dir with script
maindir='p:\1200279-eco-model-inventory\EMI\Building_Blocks\Data\NetCDF_data\River_Loads\Knowseas_111121(units_converted)\';
maindir2='p:\mcdata\opendap.deltares.nl\rijkswaterstaat\waterbase\';

%%% options
year=2007; %%% choose year of the output dis file

%%% user variables
%%%% list of rivers for discharge
mysubstance={'water_volume_transport_into_sea_water_from_rivers'};
listofmyrivers= ...
    {'ADUR','ALMOND','ARUN','AVON_AT_BOURNEMOUTH','Authie','BABINGLEY', ...
    'BLYTH','Brede','Brons','CHELMER','COLNE','COQUET','CUCKMERE','Canche', ...
    'DEE_AT_ABERDEEN','DIGHTY_WATER','DON','Den_Oever','EARN', ...
    'EDEN_IN_SCOTLAND','ESK_AT_EDINBURGH','ESK_AT_WHITBY','EYE_WATER', ...
    'Elbe','Ems','FIRTH_OF_FORTH','FROME','GIPPING','GREAT_STOUR', ...
    'GYPSEY_RACE','Grona','HUMBER','ITCHEN','Jordbro','Karup','Konge', ...
    'Kornwerderzand','LEVEN_IN_SCOTLAND','LUD','LYMN','MEDWAY','MEON', ...
    'Meuse','NENE','NORTH_ESK','North_Sea_Canal','OUSE_AT_KINGS_LYNN', ...
    'OUSE_AT_NEWHAVEN','Omme','ROTHER','Rhine','Ribe','SOUTH_ESK', ...
    'STOUR_AT_BOURNEMOUTH','STOUR_AT_HARWICH','Scheldt','Seine','Simested', ...
    'Skals','Skjern','Sneum','Somme','Stora','TAY','TEES','TEST','THAMES', ...
    'TWEED','TYNE','TYNE_IN_SCOTLAND','Varde','Vida','WALLERS_HAVEN', ...
    'WALLINGTON','WANSBECK','WATER_OF_LEITH','WEAR','WELLAND','WITHAM', ...
    'Weser','YAR','YARE','YTHAN','UGIE'}';

%%%% for temperature
mysubstance2={'sea_surface_temperature'};
listofmyrivers2= ...
    {'Rhine','North_Sea_Canal','Meuse','Scheldt','Kornwerderzand', ...
    'Den_Oever'}';
listofmystations= ...
    {'maasss','ijmdn1','harvss','schaarvoddl','vrouwzd','vrouwzd'}'; % temperature stations

%%%% for Lake_IJssel reading discharge from waterbase instead of cefas
listofmyrivers3= ...
    {'Den_Oever','Kornwerderzand'}';
listofmystations2= ...
    {'DENOVBTN','KORNWDZBTN'}'; %temperature from waterbase

%%% numbers
nbmyrivers=size(listofmyrivers,1);
nbmyrivers2=size(listofmyrivers2,1);
nbmystations=size(listofmystations,1);

%%% hard-code (to improve later)
runid2='id44-'; %%% for waterbase (temperature)
runid3='id29-'; %%% for waterbase (discharge)
file_ext='-19770101-20091231'; %%% for cefas database
dummytemp=10; %%% for non waterbase
dateori=datenum(1970,1,1); %%%% time offset
        
%%% pre-allocation
data=zeros(nbmyrivers,9129,2);
datainfo=cell(nbmyrivers,3);
data2info=cell(nbmyrivers2,3);

%% 2 READ NETCDF FILES & WRITE OUTPUT
disp('reading netcdf files and writing dis file');

%%% open the output file
cd(localdir);
filename=[num2str(year),'_flow.dis'];
file=fopen(filename,'w+');

%%% read the netcdf data
for jj=1:nbmyrivers
mysubstance={'water_volume_transport_into_sea_water_from_rivers'};

    %%% find the correct netcdf file for discharge
    if strcmpi('Kornwerderzand',listofmyrivers{jj}) || strcmpi('Den_Oever', listofmyrivers{jj})
        %%%% path to the waterbase
        newdir=[maindir2,mysubstance{1},'\'];
        cd(newdir);
        %%%% name of the netcdf file
        alp=strmatch(listofmyrivers{jj},listofmyrivers3);
        filename=[runid3,upper(listofmystations2{alp}),'.nc'];
    else
        %%%% path to the CEFAS database
        newdir=[maindir,mysubstance{1},'\']; mysubstance={'discharge'};
        cd(newdir);
        %%%% name of the netcdf file
        filename=[lower(listofmyrivers{jj}),file_ext,'.nc'];
    end
    
    %%% load the data
    tempdata=nc_varget(filename,mysubstance);
	temptime=nc_varget(filename,'time')+dateori;
    
    %%% select the correct time-series for discharge
    mask_inf=datenum(year-1,12,31,23,59,59);
    mask_sup=datenum(year+1,1,1);
    cond=temptime>mask_inf & temptime<mask_sup;

    newdata=tempdata(cond)';
    newtime=temptime(cond); nbtimes=size(newtime,1);

    %%% associate temperature data
    if max(strcmpi(listofmyrivers{jj},listofmyrivers2))
        %%%% path to the directory (waterbase)
        newdir=[maindir2,mysubstance2{1},'\'];
        cd(newdir);
        
        %%%% open the netcdf file
        alp=strmatch(listofmyrivers{jj},listofmyrivers2);
        filename2=[runid2,upper(listofmystations{alp}),'.nc'];

        %%%% load the data
        tempdata2=nc_varget(filename2,mysubstance2);
        temptime2=nc_varget(filename2,'time')+dateori;
        
        %%% interpolation of the temperature data (need daily)
        mask_inf2=datenum(year-1,12,1); % so no NaNs
        mask_sup2=datenum(year+1,1,31);
        cond2=temptime2>=mask_inf2 & temptime2<=mask_sup2;   
        
        intdata2=interp1(temptime2(cond2),tempdata2(cond2), ...
                mask_inf2:mask_sup2,'linear');
            
        %%% select the correct time-series for temperature
        cond3=mask_inf2:mask_sup2>=mask_inf & mask_inf2:mask_sup2<=mask_sup;
        
        newdata2=intdata2(cond3)';
    else
        %%% select the correct time-series for temperature (=dummy)
        newdata2=zeros(nbtimes,1)+dummytemp;
    end
 
    %%% write the dis file
    %%%% header
    fprintf(file,'table-name          ''Discharge : %i''',jj);
    fprintf(file,'\ncontents            ''regular''');
    fprintf(file,'\nlocation            ''%s''',listofmyrivers{jj});
    fprintf(file,'\ntime-function       ''non-equidistant''');
    fprintf(file,'\nreference-time       %s0101',num2str(year));
    fprintf(file,'\ntime-unit           ''minutes''');
    fprintf(file,'\ninterpolation       ''linear''');
    fprintf(file,'\nparameter           ''time'' unit ''[min]''');
    fprintf(file,'\nparameter           ''flux/discharge rate'' unit ''[m3/s]''');
    fprintf(file,'\nparameter           ''Salinity'' unit ''[ppt]''');
    fprintf(file,'\nparameter           ''Temperature'' unit ''[°C]''');
    fprintf(file,'\nrecords-in-table     %i ',nbtimes);

    %%%% data
    for kk=1:nbtimes
    	fprintf(file,'\n%e %e %e %e', ...
                (newtime(kk)-newtime(1))*24*60, ... %%% time (in minutes)
                newdata(kk), ... %%% discharge
                0, ... %%% salinity
                newdata2(kk)); %%% temperature
    end

    fprintf(file,'\n');
    
    %%% cleaning
    clear temp* cond* new* 
end
fclose(file);


%% 5 DEBUG & FIGURE
% riv='Elbe';
% subs='ammonium';
% plot(data2(1,cond,2),data2(1,cond,1),'+k',newtime,newdata,'.--b');
% 
% hold on
% plot(data(strmatch(riv,listofmyrivers,'exact'),:,2,strmatch(subs,listofmysubstances,'exact')), ...
%      newdata(strmatch(riv,listofmyrivers,'exact'),:),'k', ...
%      data(strmatch(riv,listofmyrivers,'exact'),:,2,strmatch(subs,listofmysubstances,'exact')), ...
%      data(strmatch(riv,listofmyrivers,'exact'),:,1,strmatch(subs,listofmysubstances,'exact')),'r')

%% 6 CLEANING
cd(localdir);
