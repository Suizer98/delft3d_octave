%HIS2table example to get OSPAR csv from TBNT runs 
%
%See also: waq, delwaq

%% HIS2TABLE
%%% Reads substances from TBNT runs and outputs csv tables to fit tables for the ospar report
%%% Author: Dr M Chatelain (mathieu.chatelain@deltares.nl)
%%% Created: 18-nov-11

%%% this script is based on the his2gis script. it loads his files, identify tagged substances
%%% and perform several kind of averaged (+ standard deviation) calculations at tagged stations (=target areas)
%%% it writes an output in tables which formats are described in the "ICG-EMO guide distance to targets.docx"
%%% the averaged calculation depends on the country where the station is located:
%%% >> "winter" averaged (january + february)
%%% >> "growing season" averaged (march to october excl.) for Netherlands, Germany, UK
%%% >> "growing season" averaged (march to october incl.) for Belgium, France

%%% 1) define the correct paths to the data and local script (>USER VARIABLES >>PATHS)
%%% 2) define the averaged, areas, years, stations, countries and substances (>USER VARIABLES >>LISTS)
%%%    NB: 'listofcountries' and 'listofstations' are case sensitive
%%% 4) define the combinations of substances (>USER VARIABLES >>COMBINATIONS)
%%% 3) specify the OPT values (>USER VARIABLES >>OPTIONS)

%%% Updates:
%%% 28-nov-11
%%% >> minor correction regarding oxygen output (print minimum instead of maximum)
%%% 25-nov-11
%%% >> replaced 'listofyearslg' with 'listofyears' (long format, YYYY, 4 digits)
%%% >> minimum values for winter, year, and summer
%%% >> systematically printing out all depths (all, surface, bottom) in the output tables, and remove
%%%    unnecessary lines later in excel
%%% >> new conditions to attribute score to oxygen values
%%% >> removed the loop over the areas
%%% >> add calculation of the N/P ratio (=DIN/DIP) if needed (and if DIN and DIP are also calculated). because
%%%    mean(a/b)~=mean(a)/mean(b), it was not possible to calculate the N/P ratio from the output file (in excel)
%%% 24-nov-11 
%%% >> averaged/standard deviation/maximum for winter and year
%%% >> averaged/standard deviation/maximum for summer, depending on the duration of the 
%%%    growing period, i.e. depending on the country (>CALCULATIONS >>SUMMER SEASON)
%%% >> listofyearslg is now automated (for years>1911)
%%% >> added 'listofstationsbott' and 'listofstationssurf' for bottom and surface layer, respectively
%%%    NB: stations are not in his files now, need re-run first
%%% >> listofdepths = {'bottom','surface'} or {'all'} (order matters!)
%%% >> threshold values are hard-coded
%%% >> score is assign to (station/variable/depth/averaged) by comparison with threshold values
%%%    (only relevant score are assigned, non-relevant are skipped -> less cputime + less ram)
%%% >> table5_appendix4.csv is written correctly and successfully imported into excel
%%% >> loop over the years is now working correctly for tab5_app4 (-> writing in different csv files).

%%% To do list:
%%% >> check values for vectwinter, vectgrowingsea1 & vectgrowingsea2
%%% >> 'listofdepths' = {'all','bottom','surface'}, orders and size matter; get rid of that!

clear all; hold off; close all;


%% USER VARIABLES
disp('user variables');
%%% paths
localdir='d:\matlab'; cd(localdir);  %%% path to local script (new version)
% localdir='d:\checkouts\openearthtools\matlab\applications\delft3d\waq\'; cd(localdir); %%% path to local checkout
maindir='p:\z4351-ospar07\ICG-EMO_2010\nzbgem_backup\' %%% path to data
thresdir=localdir; %%% path to the threshold data
runid='ONA';

%%% load data
%%% the threshold data is hard-coded, according to table3 in the ICG-EMO guidance document
listofthresholdstations={'GO2','GC1','UKC1','NLO2','NLC2','NLC3','BC1','BO1','FC2','FO1'}';
listofthresholdvariables={'DIN','DIP','Chlfa','N/P','Oxygen','Phaeocystis'}';
thresholddata=[14,24,10.8,15,30,30,15,12,15,15; ... %%% DIN
   0.9,0.9,0.68,0.8,0.8,0.8,0.8,0.8,1.2,1.2; ... %%% DIP
   3,6,15,4.5,15,15,7.5,4.2,4,4; ... %%% Chla
   24,24,24,24,24,24,24,24,24,24; ... %%% N/P ratio
   6,6,6,6,6,6,6,6,6,6; ... %%% oxygen
   1e6,1e6,1e6,1e6,1e6,1e6,1e6,1e6,1e6,1e6]'; %%% Phaeocystis   

%%% season vectors
vectyear=1:52; %%% indices for years
vectwinter=[1:4,49:52]; %%% "winter" averaged (january + february)
vectgrowingsea1=13:36; %%% "growing season" (march to october excl.) for Netherlands, Germany, UK
vectgrowingsea2=9:40; %%% "growing season" (march to october incl.) for Belgium, France

%%% lists: averaged, years, stations, countries, and substances
listofaveraged={'winter','summer','year'}';
listofyears={'2002','1997','1998','1999','2000','2001'}';
listofstations={'NLC2','NLC3','NLO2','GC1','GO2','UKC1','BC1','BO1','FC2','FO1'}';
listofcountries={'NL','G','UK','B','F'}';
listofsubstances={'NH4','NO3','PO4','Chlfa','OXY','PHAEOCYS_E','PHAEOCYS_N','PHAEOCYS_P'}';
listofdepths={'all'};%,'bottom','surface'}'; %%% MODIFY CAREFULLY, ORDERS AND SIZE MATTERS!
%%% NB: Except for 'listofdepths', the order is the list does not matter.
%%%     if you want to add a new country, you have to define the length of the summer season
%%%     for this country (>CALCULATION >>SUMMER SEASON). also check that all the countries in 'listofstations'
%%%     are indeed listed in 'listofcountries' (if not, you will get an error message)

%%% additional stations
ext_bott=''; %%% extension for bottom station names
ext_surf=''; %%% extension for surface station names

%%% combinations: define the desired combination of substances(=variables) from listofsubstances
myvariablesnames={'DIN','DIP','N/P','Chlfa','Oxygen'}';
listofmyvariables={[1,2];3;1;4;5}; %%% numbers of the substances in 'listofsubstances'
%%% NB: names need to be consistent (case sensitive) with names in 'listofthresholdvariables';
%%%     the order does not matter and you don't need to have all the names from 'listofthresholdvariables'.
%%%     Note that if N/P is calculated, then DIN and DIP are required (N/P = DIN/DIP).
%%%     You can choose any substance for N/P, it does not intervene in the calculation. But you have to choose
%%%     at least one, otherwise you'll get an error for inconsistency in the size of the 'listofmyvariables'.
%%%     (by default you should choose 1).

%%% output options
OPT.table.write=1; %%% output in (table2_appendix2) format
OPT.table2.write=1; %%% woutput in (table5_appendix4) format


%% GLOBAL PARAMETERS
%%% numbers
nbaveraged=size(listofaveraged,1);
nbyears=size(listofyears,1);
nbstations=size(listofstations,1);
nbcountries=size(listofcountries,1);
nbsubstances=size(listofsubstances,1);
nbmyvariables=size(myvariablesnames,1);
nblistofmyvariables=size(listofmyvariables,1);
nbdepths=size(listofdepths,1);

%%% initialisation
listofstationsbott=cell(nbstations,1);
listofstationssurf=cell(nbstations,1);

%%% additional stations for surface and bottom layers
for nn=1:nbstations
    listofstationsbott{nn}=[listofstations{nn},ext_bott]; %%% stations name for bottom layer
    listofstationssurf{nn}=[listofstations{nn},ext_surf]; %%% stations name for surface layer
end
listofstations=[listofstations;listofstationsbott;listofstationssurf];
nbstations=size(listofstations,1);


%% ERROR message
%%% check if user variables are not consistent before proceeding
if nbmyvariables ~= nblistofmyvariables %%% inconsistency in myvariables
    disp('calculation stopped');
    disp('check >USER VARIABLES for inconsistencies');
    break    
end


%% CALCULATIONS
disp('calculations');
%%% initialisation
outputdata=zeros(nbstations,nbaveraged,nbmyvariables,4,nbyears); %%% output matrix data
score=cell(nbstations,nbaveraged,nbmyvariables,nbyears); %%% score according to local threshold
listofmystations=zeros(nbstations,1); %%% chosen stations
listofmysubstances=zeros(nbsubstances,1); %%% chosen substances
countryid=zeros(nbstations,nbcountries); %%% which station in which country
vectgrowingseason=cell(1,nbstations); %%% summer growing season per station

%%% summer season
%%%% growing season length is depending on the country
for oo=1:nbcountries %%% loop over the countries
    countryid(:,oo)=strncmp(listofcountries{oo},listofstations,size(listofcountries{oo},2)); %%% which station is in which country
end

for nn=1:nbstations %%% assign the correct length of the summer growing season
    if countryid(nn,strmatch('NL',listofcountries)) || countryid(nn,strmatch('G',listofcountries)) || ...
            countryid(nn,strmatch('UK',listofcountries)) %%% if stations is in nl, germany, or uk
        vectgrowingseason{nn}=vectgrowingsea1;
    elseif countryid(nn,strmatch('B',listofcountries)) || countryid(nn,strmatch('F',listofcountries))
        vectgrowingseason{nn}=vectgrowingsea2; %%% or if the station is in belgium or france
    else
        fprintf('\nThe country of station %s is unknown.',listofstations{nn});
        fprintf('\nCalculation stopped.');
        break
    end 
end

%%% main loop
for kk=1:nbyears %%% loop over the years
    alp=char(listofyears{kk}); %%% short format (YY)
    foldername=[runid,alp(1,3:4)]; %%%% name of the new folder
    cd(maindir); cd(foldername); %%%% change path to new folder
    struct=delwaq('open','TBNT.HIS'); %%%% load data

if kk==1 %% choose stations and substances (to do only once)
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

    for mm=1:nbmyvariables %%% loop over myvariables
        if strncmp('N/P',myvariablesnames{mm},3)
            tempdata=sum(data(listofmyvariables{strmatch('DIN',myvariablesnames,'exact')},:,:),1)./ ...
                sum(data(listofmyvariables{strmatch('DIP',myvariablesnames,'exact')},:,:),1);
        else
            tempdata=sum(data(listofmyvariables{mm},:,:),1); %%% myvariables (=sum of substances)
        end
        
        for ll=1:nbaveraged %%% loop over the time-period averaged
        
        if strncmp('winter',listofaveraged{ll},6)
            vect=vectwinter; %%% winter averaged
        elseif strncmp('year',listofaveraged{ll},4)
            vect=vectyear; %%% year averaged
        else
            vect=vectgrowingseason; %%% summer averaged
        end
        
        if strncmp('summer',listofaveraged{ll},6); %%% summer = station by station 
            for nn=1:nbstations %%% because of different growing season per countries
                outputdata(nn,ll,mm,1,kk)=mean(tempdata(:,nn,vect{nn}),3);
                outputdata(nn,ll,mm,2,kk)=std(tempdata(:,nn,vect{nn}),0,3);
                outputdata(nn,ll,mm,3,kk)=max(tempdata(:,nn,vect{nn}),[],3)';
                outputdata(nn,ll,mm,4,kk)=min(tempdata(:,nn,vect{nn}),[],3)';
            end
        else %%% otherwise (year, winter)
            outputdata(:,ll,mm,1,kk)=mean(tempdata(:,:,vect),3)';
            outputdata(:,ll,mm,2,kk)=std(tempdata(:,:,vect),0,3)';
            outputdata(:,ll,mm,3,kk)=max(tempdata(:,:,vect),[],3)';
            outputdata(:,ll,mm,4,kk)=min(tempdata(:,:,vect),[],3)';
        end
        end
         
        clear tempdata %%% cleaning
    end
    
    clear struct data %%% cleaning
end


%% WRITING OUTPUT
%%% tab2_app2 of the "ICG-EMO Guide Distance to Target.docx"
if OPT.table.write 
    disp('writing output (table)');
    
    cd(localdir); tablename=['tab2app3','.csv'];
    table=fopen(tablename,'w');
    fprintf(table,'Target area,Averaged,Depth');

    %%%%% header of the file
    for kk=1:nbyears %%% loop over the years
        fprintf(table,',%s, ',listofyears{kk});
    end
    
    %%%%% data
    for nn=1:nbstations/3 %%% loop over the stations
        fprintf(table,'\n%s, , ',listofstations{nn}); %%% name of the station
    
    %%%%% header of data
        for kk=1:nbyears %%% loop over the years
        	fprintf(table,',mean,std');
        end
            
        for mm=1:nbmyvariables %%% loop over myvariables
    %%%%% find relevant season depending on variable
        if strncmp('DIN',myvariablesnames{mm},3) || strncmp('DIP',myvariablesnames{mm},3) || strncmp('N/P',myvariablesnames{mm},3)
        	indave=strmatch('winter',listofaveraged,'exact'); %%% = winter for din, dip, n/p
    	elseif strncmp(myvariablesnames{mm},'Chlfa',5)
        	indave=strmatch('summer',listofaveraged,'exact'); %%% = summer for chlfa 
        end
        
    %%%%% print the values in the table
            for pp=1:nbdepths
                incr=(pp-1)*nbstations/nbdepths;
                fprintf(table,'\n%s,%s,%s',myvariablesnames{mm},listofaveraged{indave},listofdepths{pp});
                for kk=1:nbyears %%% loop over the years
                    fprintf(table,',%1.6f,%1.6f', ...
                            outputdata(incr+nn,indave,mm,1,kk),outputdata(incr+nn,indave,mm,2,kk));
                end
            end
        end
    end
    fclose(table); %%% close the file
end


%%% tab5_app4 of the "ICG-EMO Guide Distance to Target.docx"
if OPT.table2.write  
    disp('writing output (table2)');

	kk=strmatch('2002',listofyears);
    cd(localdir); table2name=['tab5_app4_',listofyears{kk},'.csv'];
    table2=fopen(table2name,'w');
    
    %%%% header of the file
    fprintf(table2,' , , ');
    for nn=1:nbstations/3 %%% loop over the stations
        fprintf(table2,',%s, , , , ',listofstations{nn});
    end
    fprintf(table2,'\nvariable,averaged,depth');
    for nn=1:nbstations/3  %%% loop over the stations
        fprintf(table2,',thres,mean,std,max/min,score');
    end
    
    %%%% data of the csv file
    for mm=1:nbmyvariables %%% loop over the variables
        
    %%%% choose season depending on variable
	if strncmp('DIN',myvariablesnames{mm},3) || strncmp('DIP',myvariablesnames{mm},3) || strncmp('N/P',myvariablesnames{mm},3)
    	indave=strmatch('winter',listofaveraged,'exact'); %%% = winter for din, dip, n/p
	elseif strncmp(myvariablesnames{mm},'Chlfa',5)
    	indave=strmatch('summer',listofaveraged,'exact'); %%% = summer for chlfa 
    else
        indave=strmatch('year',listofaveraged,'exact'); %%% = year if unknown
	end
        
        for pp=1:nbdepths %%% loop over the depths
            incr=(pp-1)*nbstations/nbdepths;
            fprintf(table2,'\n%s,%s,%s',myvariablesnames{mm},listofaveraged{indave},listofdepths{pp});
                
   %%%% find the threshold value
            for nn=1:nbstations/3 %%% loop over the station
                indvariable=strmatch(myvariablesnames{mm},listofthresholdvariables,'exact');
                indstation=strmatch(listofstations{nn},listofthresholdstations,'exact');
                thresholdvalue=thresholddata(indstation,indvariable); %%% threshold value
                
        %%%% assign a score
            if strncmp('Oxygen',myvariablesnames{mm},6) %%% specific conditions for oxygen (careful: case sensitive name)
                if outputdata(incr+nn,indave,mm,1,kk) <= thresholdvalue || outputdata(incr+nn,indave,mm,4,kk) <= thresholdvalue
                    score{incr+nn,indave,mm,kk}={'++'};
                elseif outputdata(incr+nn,indave,mm,1,kk)-outputdata(incr+nn,indave,mm,2,kk) <= thresholdvalue
                    score{incr+nn,indave,mm,kk}={'OO'};
                else
                    score{incr+nn,indave,mm,kk}={'--'};
                end

            %%%% print the result in the table         
            fprintf(table2,',%1.4f,%1.4f,%1.4f,%1.4f,%s',thresholddata(indstation,indvariable), ...
                        outputdata(incr+nn,indave,mm,1,kk),outputdata(incr+nn,indave,mm,2,kk), ...
                        outputdata(incr+nn,indave,mm,4,kk),char(score{incr+nn,indave,mm,kk}));

            else %%% normal conditions for all the other parameters
                if outputdata(incr+nn,indave,mm,1,kk) >= thresholdvalue || outputdata(incr+nn,indave,mm,3,kk) >= thresholdvalue
                    score{incr+nn,indave,mm,kk}={'++'};
                elseif outputdata(incr+nn,indave,mm,1,kk)+outputdata(incr+nn,indave,mm,2,kk) >= thresholdvalue
                    score{incr+nn,indave,mm,kk}={'OO'};
                else
                    score{incr+nn,indave,mm,kk}={'--'};
                end

            %%%% print the result in the table         
            fprintf(table2,',%1.4f,%1.4f,%1.4f,%1.4f,%s',thresholddata(indstation,indvariable), ...
                        outputdata(incr+nn,indave,mm,1,kk),outputdata(incr+nn,indave,mm,2,kk), ...
                        outputdata(incr+nn,indave,mm,3,kk),char(score{incr+nn,indave,mm,kk}));
            end
            end
        end
    end
    fclose(table2);
end

break
%% CLEANING
cd(localdir);
clear *dir f* list* *name* nb* *my* var* vect*

