
%% NETCDF2LOA
%%% Author: Dr M. Chatelain (mathieu.chatelain@deltares.nl)
%%% Created: 28-nov-11

%%% Matlab code to convert NetCDF data to loads files for Delwaq.

%%% 1a PREPARATION>>PATHS
%%% 1b PREPARATION>>OPTIONS

%%% IMPORTANT: 'listofmysubstances' has same names as the folder names in maindir
%%%            'listofmyrivers'has same names as file in maindir/substance
%%% to do list:
%%% >> specific corrections for lake_ijssel
%%% >> automate 'listofriverspercountry'??
%%% >> load only time series once?
%%% >> automate listofrivers_ospar
%%% >> automate nbtimes

clear all; hold off; close all; fclose all;


%% 1a PREPARATION
disp('preparation');
%%% paths
localdir='d:\matlab\'; %%% local dir
maindir='d:\projects\120-northseamodelling\Loads_CEFAS_1985_2009_old\'; %%% local data dir
% maindir='p:\1200279-eco-model-inventory\EMI\Building_Blocks\Data\NetCDF_data\River_Loads\Loads_CEFAS_1985_2009\' %%% remote data dir
runid='cefas'; %%% run id

%%% lists of substances
listofsubstances={'','','ammonium','DIC','DIN','Discharge','DOC','nitrate','nitrite','phosphate', ...
	'silicate','SPM','TALK','Total_N','Total_P'}';

%%% listofrivers
%%%% emt_rivers
%%%% NB: these rivers are NOT assigned to a country and are not printed out in .country files
listofrivers_emt={'BABINGLEY','Brede','Brons','GYPSEY_RACE','Grona','Jordbro','Karup','Konge','LUD','LYMN','MEON', ...
    'Omme','Ribe','Simested','Skals','Skjern','Sneum','Stora','Varde','Vida','WALLERS_HAVEN','WALLINGTON','YAR'}';
%%%% ospar_rivers
listofrivers_ospar={ ...
	'Elbe','Ems','Weser', ... %%% Germany
	'Authie','Canche','Seine','Somme', ... %%% France
	'ADUR','ARUN','AVON_AT_BOURNEMOUTH','CHELMER','COLNE','CUCKMERE','FROME','GIPPING','GREAT_STOUR','ITCHEN', ...
	'MEDWAY','OUSE_AT_NEWHAVEN','ROTHER','STOUR_AT_BOURNEMOUTH','STOUR_AT_HARWICH','TEST','THAMES', ... %%% UK1
	'ALMOND','BLYTH','COQUET','DEE_AT_ABERDEEN','DIGHTY_WATER','DON','EARN','EDEN_IN_SCOTLAND','ESK_AT_EDINBURGH', ...
	'ESK_AT_WHITBY','EYE_WATER','FIRTH_OF_FORTH','HUMBER','LEVEN_IN_SCOTLAND','NENE','NORTH_ESK','OUSE_AT_KINGS_LYNN', ...
	'SOUTH_ESK','TAY','TEES','TWEED','TYNE','TYNE_IN_SCOTLAND','UGIE','WANSBECK','WATER_OF_LEITH','WEAR','WELLAND', ...
	'WITHAM','YARE','YTHAN', ... %%% UK2
	'Meuse','North_Sea_Canal','Rhine', ... %%% NL1
	'Lake_IJssel', ... %%% NL2
	'Scheldt'}'; %%% Belgium
%%%% ospar_rivers per country
rivge={'Elbe','Ems','Weser'};
rivfr={'Authie','Canche','Seine','Somme'};
rivuk1={'ADUR','ARUN','AVON_AT_BOURNEMOUTH','CHELMER','COLNE','CUCKMERE','FROME','GIPPING','GREAT_STOUR','ITCHEN', ...
	'MEDWAY','OUSE_AT_NEWHAVEN','ROTHER','STOUR_AT_BOURNEMOUTH','STOUR_AT_HARWICH','TEST','THAMES'};
rivuk2={'ALMOND','BLYTH','COQUET','DEE_AT_ABERDEEN','DIGHTY_WATER','DON','EARN','EDEN_IN_SCOTLAND','ESK_AT_EDINBURGH',...
	'ESK_AT_WHITBY','EYE_WATER','FIRTH_OF_FORTH','HUMBER','LEVEN_IN_SCOTLAND','NENE','NORTH_ESK','OUSE_AT_KINGS_LYNN',...
	'SOUTH_ESK','TAY','TEES','TWEED','TYNE','TYNE_IN_SCOTLAND','UGIE','WANSBECK','WATER_OF_LEITH','WEAR','WELLAND',...
	'WITHAM','YARE','YTHAN'};
rivnl1={'Meuse','North_Sea_Canal','Rhine'};
rivnl2={'Lake_IJssel'};
rivbe={'Scheldt'};


%% 1b PREPARATION
%%% options
OPT.ospar=1; %%% corrections for ospar
OPT.knowseas=0; %%% corrections for knowseas
OPT.loa=1; %%% write .loa files
OPT.loacountry=1; %%% write .country files

%%% user variables
listofmysubstances={'Discharge','ammonium','nitrate','nitrite','Total_P','phosphate','silicate'}';
listofmyrivers=[listofrivers_ospar]; %%%;listofrivers_emt];
listofriverspercountry={rivge;rivfr;rivuk1;rivuk2;rivnl1;rivnl2;rivbe};
listofcountries={'GE','FR','UK1','UK2','NL1','NL2','BE'}';
listofcorrectedsubstances={'ammonium','nitrate','phosphate','silicate'}';
listofyears={'1985';'2009'};

%%%% thresholds and conversion
threshold=-1e-5;
limit=1e-10;
factorconversion=1e6/86400;


%% 1c PREPARATION
%%% time
vectyears=[str2double(char(listofyears{1})):str2double(char(listofyears{2}))]';
%%% numbers
nbmysubstances=size(listofmysubstances,1);
nbmyrivers=size(listofmyrivers,1);
nbriverspercountry=size(listofriverspercountry,1);
nbcountries=size(listofcountries,1);
nbyears=size(vectyears,1);
nbcorrections=size(listofcorrectedsubstances,1);
nbtimes=nbyears*365+roundoff(nbyears/4,0,'floor')-2;
%%% extensions
extyear=['_',listofyears{1},'_',listofyears{2}];
%%% pre-allocation
data=zeros(nbmyrivers,nbtimes,2,nbmysubstances);
datainfo=cell(nbmyrivers,3);


%% 1d PREPARATION
%%% verifications
if (OPT.ospar && OPT.knowseas) || (~OPT.ospar && ~OPT.knowseas)
    disp('>1b PREPARATION>>OPTIONS: Error 1.');
    break
elseif nbcountries ~= nbriverspercountry
    disp('>1b PREPARATION>>USER VARIABLES: Error 1.');
    break
elseif (nbmyrivers ~= size(listofrivers_ospar,1) && OPT.ospar) || ...
        (nbmyrivers ~= size(listofrivers_ospar,1)+size(listofrivers_emt,1) && OPT.knowseas)
    disp('>1b PREPARATION>>USER VARIABLES: Error 2.');
    break    
end


%% 2 READ NETCDF FILES
tic
disp('read netcdf files');
for ii=1:nbmysubstances
    newdir=[maindir,listofmysubstances{ii},'\'];
    cd(newdir);
    
    for jj=1:nbmyrivers
        filename=[listofmyrivers{jj},extyear,'.nc'];
        
        data(jj,:,1,ii)=nc_varget(filename,listofmysubstances{ii});
        data(jj,:,2,ii)=nc_varget(filename,'time');
        
        datainfo{jj,1}=listofmyrivers{jj};
        datainfo{jj,2}=nc_varget(filename,'lat')';
        datainfo{jj,3}=nc_varget(filename,'lon')';
    end
    
end
toc

%% 3 UNIT CONVERSION AND DATA CORRECTIONS
disp('unit conversion and data corrections')
newdata=data;

%%% CORRECTIONS FOR THE OSPAR RUNS
if OPT.ospar
for ii=1:nbcorrections %%% loop over the substances that need corrections
    tempdata=data(:,:,1, ...
        strmatch(listofcorrectedsubstances{ii},listofmysubstances,'exact'));

if strcmp('ammonium',listofcorrectedsubstances{ii}) || strcmp('phosphate',listofcorrectedsubstances{ii}) || ...
        strcmp('silicate',listofcorrectedsubstances{ii})
    %%% corrections (NaN)
    cond1=isnan(tempdata) | tempdata<=threshold;
    tempdata(cond1)=limit;
    
    %%% corrections (update) = NONE
    %%% conversion
    convcond=tempdata~=limit;

elseif strcmp('nitrate',listofcorrectedsubstances{ii})
    %%% find nitrates
    jj=strmatch('nitrite',listofmysubstances,'exact');
	tempdata2=data(:,:,1,jj);
    
    %%% corrections (NaN)
    cond1=isnan(tempdata) & isnan(tempdata2);
    cond2=isnan(tempdata) & tempdata2<=threshold;
    cond3=tempdata<=threshold & isnan(tempdata2);
    cond4=tempdata<=threshold & tempdata2<=threshold;

    tempdata(cond1|cond2|cond3|cond4)=limit;
    
    %%% corrections (update)
    conda=tempdata2~=limit & isnan(tempdata);
    condb=tempdata2~=limit & tempdata<=threshold;
    condc=tempdata~=limit & isnan(tempdata2);
    condd=tempdata~=limit & tempdata2<=threshold;
    conde=tempdata~=limit & tempdata2~=limit & ~conda & ~condb & ~condc & ~condd;
    
	tempdata(conda|condb)=tempdata2(conda|condb);
    tempdata(condc|condd)=tempdata(condc|condd);
    tempdata(conde)=(tempdata(conde)+tempdata2(conde));
   
    %%% conversion
    convcond=tempdata~=limit;
end
    
    tempdata(convcond)=tempdata(convcond).*factorconversion; %%% unit conversion
    newdata(:,:,1, ... %%% replace data by corrected data
            strmatch(listofcorrectedsubstances{ii},listofmysubstances,'exact'))=tempdata;
    clear tempdata tempdata2 con*
end
end

%%% CORRECTIONS FOR THE KNOWSEAS RUNS
if OPT.knowseas
for ii=1:nbcorrections %%% loop over the substances that need corrections
    tempdata=data(:,:,1, ...
            strmatch(listofcorrectedsubstances{ii},listofmysubstances,'exact'));

if strcmp('ammonium',listofcorrectedsubstances{ii}) 
    %%% corrections (NaN)
    cond1=isnan(tempdata) | tempdata<=threshold;
    tempdata(cond1)=limit;
    %%% corrections (update) = NONE
    %%% conversion
    convcond=tempdata~=limit;
    
elseif strcmp('nitrate',listofcorrectedsubstances{ii}) || strcmp('phosphate',listofcorrectedsubstances{ii}) || ...
       	strcmp('silicate',listofcorrectedsubstances{ii})

    %%% find relevant complementary substance
    if strcmp('nitrate',listofcorrectedsubstances{ii})
        jj=strmatch('nitrite',listofmysubstances,'exact');
    elseif strcmp('phosphate',listofcorrectedsubstances{ii})
        jj=strmatch('Total_P',listofmysubstances,'exact');
    elseif strcmp('silicate',listofcorrectedsubstances{ii})
        jj=strmatch('Discharge',listofmysubstances,'exact'); 
    end
	tempdata2=data(:,:,1,jj);
    
    %%% corrections (NaN)
    cond1=isnan(tempdata) & isnan(tempdata2);
    cond2=isnan(tempdata) & tempdata2<=threshold;
    cond3=tempdata<=threshold & isnan(tempdata2);
    cond4=tempdata<=threshold & tempdata2<=threshold;

    tempdata(cond1|cond2|cond3|cond4)=limit;
    
    %%% corrections (update)
    %%%% common nitrate and phosphate
    conda=tempdata2~=limit & isnan(tempdata);
    condb=tempdata2~=limit & tempdata<=threshold;
    condc=tempdata~=limit & isnan(tempdata2);
    condd=tempdata~=limit & tempdata2<=threshold;
    conde=tempdata~=limit & tempdata2~=limit & ~conda & ~condb & ~condc & ~condd;
    %%%% for phosphate only
    condf=conde & tempdata==tempdata2;
    %%%% for silicate only
    condg=isnan(tempdata);
    condh=tempdata<=threshold;
    
    if strcmp('nitrate',listofcorrectedsubstances{ii})
        %%% corrections
        tempdata(conda|condb)=tempdata2(conda|condb);
        tempdata(condc|condd)=tempdata(condc|condd);
        tempdata(conde)=(tempdata(conde)+tempdata2(conde));
        %%% conversion
        convcond=tempdata~=limit;
    elseif strcmp('phosphate',listofcorrectedsubstances{ii})
        %%% corrections
        tempdata(conda|condb)=tempdata2(conda|condb);
        tempdata(condc|condd)=tempdata(condc|condd);
        tempdata2(condf)=1.42.*tempdata(condf)+0.07; %%% Meuwese, 2007
        tempdata(conde)=tempdata(conde)+0.25*(tempdata2(conde)-tempdata(conde));
        %%% conversion
        convcond=tempdata~=limit;
    elseif strcmp('silicate',listofcorrectedsubstances{ii})
        %%% corrections
        tempdata(condg|condh)=tempdata2(condg|condh).*10;
        %%% corrections
        convcond=tempdata~=limit & ~condg & ~condh;
    end
end   

    tempdata(convcond)=tempdata(convcond).*factorconversion; %%% unit conversion
    newdata(:,:,1, ... %%% replace data by corrected data
            strmatch(listofcorrectedsubstances{ii},listofmysubstances,'exact'))=tempdata;
    clear tempdata tempdata2 con*
end
end


%% 4a WRITING OUTPUT
disp('writing output:')
%%% create new folder to store output files
if OPT.ospar
    cd(localdir); mkdir('ospar'); cd('ospar');
elseif OPT.knowseas
    cd(localdir); mkdir('knowseas'); cd('knowseas');
end

%% 4b WRITING OUTPUT: .LOA FILES PER YEAR
if OPT.loa
disp('.loa files per year');
for ii=1:nbyears
    filename=[runid,num2str(vectyears(ii)),'.loa'];
    file=fopen(filename,'w');
    
    for jj=1:nbmyrivers
    	vtime=newdata(jj,:,2,1)';
        mask_inf=datenum(vectyears(ii),1,1);
        mask_sup=datenum(vectyears(ii),12,31);
        cond=vtime>=mask_inf & vtime<=mask_sup;
        tempdata=newdata(jj,cond,1,:);
        nbtimesteps=size(tempdata,2);
        
        fprintf(file,'ITEM');
        fprintf(file,'\n  ''%s''',datainfo{jj});
        fprintf(file,'\nCONCENTRATIONS');
   	    fprintf(file,'\n   USEFOR ''FLOW''   ''new_discharge''');
        fprintf(file,'\n   USEFOR ''FrFlow'' ''discharge''     MIN 0');
        fprintf(file,'\n   USEFOR ''NH4''    ''new_ammonium''  MIN 0');
        fprintf(file,'\n   USEFOR ''NO3''    ''new_nitrate''   MIN 0');
        fprintf(file,'\n   USEFOR ''PO4''    ''new_phosphate'' MIN 0');
        fprintf(file,'\n   USEFOR ''Si''     ''new_silicate''  MIN 0');
        fprintf(file,'\nTIME LINEAR');
        fprintf(file,'\nDATA');
        fprintf(file,'\n''discharge''''new_discharge''''new_ammonium''''new_nitrate''''new_phosphate''''new_silicate''\n');

        for kk=1:nbtimesteps
            fprintf(file,'%i000000 %i 0 %e %e %e %e\n',(kk-1), ...
                    tempdata(1,kk,1,strmatch('Discharge',listofmysubstances,'exact')), ...
                    tempdata(1,kk,1,strmatch('ammonium',listofmysubstances,'exact')), ...
                    tempdata(1,kk,1,strmatch('nitrate',listofmysubstances,'exact')), ...
                    tempdata(1,kk,1,strmatch('phosphate',listofmysubstances,'exact')), ...
                    tempdata(1,kk,1,strmatch('silicate',listofmysubstances,'exact')));
        end
    end
    fprintf(file,'; eof');
    fclose(file);    
end
end

%% 4c WRITING OUTPUT: .LOACOUNTRY FILES PER YEAR
if OPT.loacountry
disp('.loacountry files per year');
for ll=1:nbcountries
	rivers=listofriverspercountry{ll}';
	nbrivers=size(rivers,1);
    
    for ii=1:nbyears        
        filename2=[runid,num2str(vectyears(ii)),'.',listofcountries{ll}];
        file2=fopen(filename2,'w');
        
        for jj=1:nbrivers
            realjj=strmatch(rivers{jj},listofmyrivers,'exact');
            vtime=newdata(realjj,:,2,1)';
            mask_inf=datenum(vectyears(ii),1,1);
            mask_sup=datenum(vectyears(ii),12,31);
            cond=vtime>=mask_inf & vtime<=mask_sup;
            tempdata=newdata(realjj,cond,1,:);
            nbtimesteps=size(tempdata,2);
        
            fprintf(file2,'ITEM');
            fprintf(file2,'\n  ''%s''',listofmyrivers{realjj});
            fprintf(file2,'\nCONCENTRATIONS');
            fprintf(file2,'\n   USEFOR ''NH4-r''    ''new_ammonium''  MIN 0');
            fprintf(file2,'\n   USEFOR ''NO3-r''    ''new_nitrate''   MIN 0');
            fprintf(file2,'\n   USEFOR ''PO4-r''    ''new_phosphate'' MIN 0');
            fprintf(file2,'\nTIME LINEAR');
            fprintf(file2,'\nDATA');
            fprintf(file2,'\n''new_ammonium''''new_nitrate''''new_phosphate''\n');

            for kk=1:nbtimesteps
                fprintf(file2,'%i000000 %e %e %e\n',(kk-1), ...
                        tempdata(1,kk,1,strmatch('ammonium',listofmysubstances,'exact')), ...
                        tempdata(1,kk,1,strmatch('nitrate',listofmysubstances,'exact')), ...
                        tempdata(1,kk,1,strmatch('phosphate',listofmysubstances,'exact')));
            end
        end
        fprintf(file2,'; eof');
        fclose(file2);
    end
end
end


%% 5 FIGURE
% riv='Elbe';
% subs='ammonium';
% 
% hold on
% plot(data(strmatch(riv,listofmyrivers,'exact'),:,2,strmatch(subs,listofmysubstances,'exact')), ...
%      newdata(strmatch(riv,listofmyrivers,'exact'),:),'k', ...
%      data(strmatch(riv,listofmyrivers,'exact'),:,2,strmatch(subs,listofmysubstances,'exact')), ...
%      data(strmatch(riv,listofmyrivers,'exact'),:,1,strmatch(subs,listofmysubstances,'exact')),'r')

%% 6 CLEANING
cd(localdir);


% %%%% TEST
% ii=3; %%% =3 for NO3, =6 for PO4, =7 for Si
% tempdata=[2;-1;2;2;NaN;-1;4;NaN;-1;NaN];
% tempdata2=[14.5;14.8;14.2;NaN;3;-1;4;NaN;NaN;-1];
% ori=[tempdata,tempdata2];


