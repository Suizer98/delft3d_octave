%HIS2GIS  example to get csv of concentrations for tagged substances/areas from TBNT runs 
%
%See also: waq, delwaq

%% HIS2GIS
%%% Reads substances from TBNT runs and outputs csv tabels with concentrations for each tagged substance and area
%%% Author: Dr M Chatelain (mathieu.chatelain@deltares.nl)
%%% Created: 11-nov-11

%%% load his files, identify tagged substances and perform yearly/seasonaly averaged and standard deviation
%%% per area, per station, and per year for the OSPAR runs. write output in tables
%%% (stations x areas) in a GIS format (comma separated values)

%%% 1) define the correct paths to the data and local script (>PREPARATION >>PATH)
%%% 2) define the averaged, areas, years, stations and substances (>USER VARIABLES >>LISTS)
%%% 3) specify the OPT values (>USER VARIABLES >>OPTIONS)
%%% 4) define the user variables, i.e. the combinations of substances (>USER VARIABLES >>COMBINATIONS)

%%% Updates:
%%% 25-nov-11
%%% >> new warning message if any substances in 'listofsubstances' has a time-series of zeros
%%% >> added OPT.warning to turn on/off warning messages
%%% 24-nov-11
%%% >> removed 'listofyearslg' and changed 'listofyears' definition. no more wrong naming for csv output files.
%%% 21-nov-11
%%% >> new options:
%%% - OPT.figur.station/year/myvariable = explicitly choose the station, the year and myvariable to plot
%%%   the corresponding figure and to avoid miscounting. NB: Values are case sensitive
%%% 18-nov-11
%%% >> no more subscript2, outputfiles are directly renamed and sorted in folders (less cpu time)
%%% >> no more subscript1, 'listofmyvariables' is stored into a cell array (less cpu time)
%%% >> all characters arrays were replaced by cell arrays (less ram usage)
%%% >> additionnal statistical output (yearly standard deviation, code='year_std')
%%% >> script is now working properly if the averaged for only one season is selected and/or if the season order is 
%%%    modified in 'listofaveraged' (i.e. order in 'listofaveraged' does not matter any more)
%%% >> error message if there are inconsistencies in the definition of the user variables
%%% >> new options:
%%% - OPT.write = write output in GIS format
%%% - OPT.figur = plot figure

clear all; hold off; close all;

%% PREPARATION
disp('preparation');
%%% path
% maindir='p:\z4351-ospar07\Knowseas_2011\Postprocessing\nzbgem_backup\' %%% path to data
maindir='p:\z4351-ospar07\OSPAR_OE_backup\'
localdir='d:\matlab'; %%% path to local script
% localdir='d:\checkouts\openearthtools\matlab\applications\delft3d\waq\'; %%% path to local checkout (old version)
runid='OE';

%%% global parameters
vectwinter=[1:9,49:52]; vectspring=10:22; vectsummer=23:35; vectfall=36:48; vectyear=1:52; %%% output per week
vectseasons=[vectwinter;vectspring;vectsummer;vectfall]; vectseasonsnames={'winter','spring','summer','fall'}';

%% USER VARIABLES
disp('user variables');
%%% options
OPT.warning=1; %%% turn on warning messages
OPT.write=1; %%% write output files in GIS format (default=1);
OPT.figure.write=0; %%% plot figure with results (default=0);
OPT.figure.station='Noordzee';
OPT.figure.myvariable='PO4r';
OPT.figure.year='2002';

%%% lists
%%% averaged, areas, years, years(long), stations, and substances
listofaveraged={'year'};%,'fall','spring','summer','winter','year_std'}';
listofareas={'','BE','FR','GM','NL1','NL2','UK1','UK2','CH','NA','ATM'}';
listofyears={'2002'};%'1996','1997','1998','1999','2000','2001','2002'}'; %%% format=YYYY 
listofstations={'Noordzee','UKC6','UKO5','NO2','DO1','DC1','UKC5','UKC4','DO2','UKC3', ... %%% 10
    'UKO4','NLO3','GO3','DWD1','UKO3','GO2','NLO2','DWD2','UKC2','UKO2', ... %%% 20
  'GO1','GC1','UKC1','GWD1','UKO1','NLO1a','NLO1b','UKC7','BO1','FO1', ... %%% 30
    'UKC8','BC1','NLC1','NLC2a','NLC2b','NLC3','UKC9','FC2','FC1','GWD2',... %%% 40
    'NLWD'}';
listofsubstances={'DetN-r','DetP-r','NH4-r','NO3-r','PO4-r','DIN_E-N-r','DIN_N-N-r','DIN_P-N-r','MDI_E-N-r','MDI_N-N-r', ... %%% 10
    'MDI_P-N-r','MFL_E-N-r','MFL_N-N-r','MFL_P-N-r','PHA_E-N-r','PHA_N-N-r','PHA_P-N-r','DIN_E-P-r','DIN_N-P-r','DIN_P-P-r', ... %%% 20
    'MDI_E-P-r','MDI_N-P-r','MDI_P-P-r','MFL_E-P-r','MFL_N-P-r','MFL_P-P-r','PHA_E-P-r','PHA_N-P-r','PHA_P-P-r','DetNS1-r', ... %%% 30
    'DetPS1-r','Chlfa','NH4','NO3','PO4'}'; 

nbaveraged=size(listofaveraged,1);
nbareas=size(listofareas,1);
nbyears=size(listofyears,1);
nbstations=size(listofstations,1);
nbsubstances=size(listofsubstances,1);

%%% combinations
%%% define the desired combination of substances(=variables) from listofsubstances
myvariablesnames={'TNr'}; %,'AlgNr','OrgNr','NO3r','NH4r','DetNS1r','TPr','AlgPr','OrgPr','PO4r'}'; %%% names of the variables
listofmyvariables={[1,3,4,6:17]}; %;[6:17];[1,6:17];4;3;30;[2,5,18:29];[18:29];[2,18:29];5};

nbmyvariables=size(myvariablesnames,1);
nblistofmyvariables=size(listofmyvariables,1);

%%% error message
%%% check if user variables are consistent before proceeding
if OPT.warning && nbmyvariables ~= nblistofmyvariables %%% inconsistency in myvariables
    disp('calculation stopped');
    disp('check >USER VARIABLES for inconsistencies');
    break
end

%% CALCULATIONS
disp('calculations');
%%% initialisation
outputdata=zeros(nbstations,nbaveraged,nbmyvariables,nbareas,nbyears); %%% output matrix data
listofmystations=zeros(nbstations,1); %%% chosen stations
listofmysubstances=zeros(nbsubstances,1); %%% chosen substances

%%% main loop
for kk=1:nbyears %%% loop over the years
    for jj=1:nbareas %%% loop over the areas

alp=char(listofyears(kk)); %%% conversion to format YY
foldername=[runid,alp(1,3:4),listofareas{jj}]; %%%% name of the new folder
cd(maindir); cd(foldername); %%%% change path to new folder

struct=delwaq('open','TBNT.HIS'); %%%% load data

if kk==1 && jj==1 %% choose stations and substances (to do only once)
    stationsnames=struct.SegmentName; %%% all stations in the his file
    substancesnames=struct.SubsName; %%% all substances in the his file

    for ii=1:nbstations %%% find my stations
        listofmystations(ii)=strmatch(listofstations{ii},stationsnames,'exact');
    end
    
    for ii=1:nbsubstances %%% find my substances
        listofmysubstances(ii)=strmatch(listofsubstances{ii},substancesnames,'exact');
    end
    
end

[~,data]=delwaq('read',struct,listofmysubstances,listofmystations,vectyear); %%% read data

for mm=1:nbmyvariables
    tempdata=sum(data(listofmyvariables{mm},:,:),1);
   
    for ll=1:nbaveraged
        if strmatch(listofaveraged{ll},'year','exact') %%% time (yearly-averaged) data
    outputdata(:,ll,mm,jj,kk)=mean(tempdata(:,:,vectyear),3)';
        elseif strmatch(listofaveraged{ll},'year_std','exact') %%% yearly standard deviation
    outputdata(:,ll,mm,jj,kk)=std(tempdata(:,:,vectyear),0,3)';
        else
    ind=strmatch(listofaveraged{ll},vectseasonsnames,'exact'); %%% find the relevant season
    outputdata(:,ll,mm,jj,kk)=mean(tempdata(:,:,vectseasons(ind,:)),3)'; %%% seasonal-averaged data
        end
    end
    
    clear tempdata %%% cleaning
end

%%% control check for time-series of zeros for any substances
alarm=sum(sum(isinf(1./data),3),2);
crit=size(vectyear,2)*nbstations;
if OPT.warning && max(alarm)-crit==0
    fprintf('\nTime-series of zeros detected for %s%s%s',runid,listofareas{jj},alp(1,3:4))
    fprintf('\nProceeding...')
end
    
clear struct data %%% cleaning
    end
end


%% WRITING OUTPUT
if OPT.write %%% csv files in GIS format
    disp('writing output (gis)');
    for ll=1:nbaveraged %%% loop over the averaged
    cd(localdir);
    subfoldername=listofaveraged{ll};
    mkdir(subfoldername); cd(subfoldername);

    for mm=1:nbmyvariables %%% loop over my variables
        for kk=1:nbyears %%% loop over the years
    
    filename=[listofyears{kk},'_', ...
        myvariablesnames{mm},'_',listofaveraged{ll},'.csv']; %%% name=year_myvariable_averaged.dat

    file=fopen(filename,'w');
    fprintf(file,'area'); %%% dummy value for 1st row, 1st column.
    
            for jj=1:nbareas %%% loop over the areas (1st row)
                fprintf(file,',%s',listofareas{jj}); %%% name of the areas
            end

            for ii=1:nbstations %%% loop over the stations (all remaining rows)
                fprintf(file,'\n%s',listofstations{ii}); %%% name of the stations
                
                for jj=1:nbareas %%% loop over the areas (all columns)
                    fprintf(file,',%1.6f',outputdata(ii,ll,mm,jj,kk)); %%% data
                end
            end

    fclose(file); %%% close the file
        end
    end
    end
end


%% FIGURE
if OPT.figure.write
    disp('figure');
    %%% outputdata(nbstations,nbaveraged,nbmyvariables,nbareas,nbyears)
    nstation=1; naveraged=2; nmyvariable=3; narea=4; nyear=5;

    %%% fig1: per averaged and per area (ex=PO4r at NorthSea station in 2001)
    order=[naveraged narea nstation nmyvariable nyear];
    dataplot=permute(outputdata,order); %% permutation of the data

    bar(dataplot(:,:, ...
        strmatch(OPT.figure.station,listofstations,'exact'), ... %%% station
        strmatch(OPT.figure.myvariable,myvariablesnames,'exact'), ... %%% myvariable
        strmatch(OPT.figure.year,listofyears,'exact')), ... %%% year
        'stacked'); axis([0 nbaveraged+1 0 0.03]);
    ylabel(myvariablesnames{strmatch(OPT.figure.myvariable,myvariablesnames,'exact')});
    legend(listofareas,'location','eastoutside');
    set(gca,'xticklabel',listofaveraged);
end
        
%% CLEANING
cd(localdir);
clear *dir f* list* *name* nb* *my* var* vect*


       