%netcdf2loa example to convert NetCDF data to loads files for DelWAQ-GEM
%
%See also: waq, delwaq

%% NETCDF2LOA
%%% Author: Dr M. Chatelain (mathieu.chatelain@deltares.nl)
%%% Created: 28-nov-11

%%% Matlab code to convert NetCDF data to loads files for DelWAQ-GEM

%%% This code was created as an alternative to NetCDF2loa_tag4. It uses
%%% matrices instead of structures. It is more efficient (around x20).

%%% Updates: Dec-11
%%% >> several improvements in the code / cleaning / reorganisation
%%% >> improved cpu time during writing output
%%% >> read external files for folders, countries and rivers
%%% >> add meta data to output files
%%% >> read two formats of CEFAS databases
%%% >> includes lake_ijssel specific corrections

%%% What you may need:
%%% >> examples of lists of folders/rivers in:
%%%    p:\z4351-ospar07\ICG-EMO_2010\opzet en info sommen\matlab\lists
%%% >> make sure folders 'lists' and 'loa' exist in maindir
%%% >> make sure 'listoffolders' & 'listofmysubstances' are in the same order !

%%% Notes
%%% >> specific corrections for lake_ijssel (knowseas) can be found in:
%%%    p:\1200279-eco-model-inventory\EMI\Building_Blocks\Data\NetCDF_data\River_Loads\Lake_IJssel\

%%% TO DO LIST:
%%% >> corrections for lake_ijssel for missing years & for clones.

clear all; hold off; close all; fclose all;
start_time=clock(); 


%% 1 PRE-RUNNING CHECKLIST
disp('pre-running checklist');

%%% general information on the script
openearth='p:\delta\svn.oss.deltares.nl\';
waqdir='openearthtools\matlab\applications\delft3d\waq\';
name_mscript=[openearth,waqdir,'netcdf2loa.m'];
versionnr='v2.0';

%%% USER-DEFINED options (0=no, 1=yes)
OPT.ospar=0; %%% corrections for ospar
OPT.knowseas=1; %%% corrections for knowseas
OPT.loa=1; %%% write .loa files
OPT.loacountry=0; %%% write .country files
OPT.loaname='knows'; %%% [generic] name of the loa files
OPT.years=1977:2009; %%% years to output (1985-2009 for ospar, 1977-2009 for knowseas)

%%% USER-DEFINED parameters
threshold=-1e-5;
limit=1e-10; %%% if value=NaN or value<threshold
factorconversion=1e6./86400; %%% conversion factor (from T/d to g/s)

%%% USER-DEFINED paths
localdir='d:\matlab\ospar_scripts\'; %[openearth,waqdir]; %%% path to script
maindir='p:\z4351-ospar07\ICG-EMO_2010\opzet en info sommen\matlab\'; %%% path to maindir
databasedir='p:\1200279-eco-model-inventory\EMI\Building_Blocks\Data\NetCDF_data\River_Loads\'; %%% path to databases
lakeijsseldir='Lake_IJssel\'; %%% path to lake ijssel corrected data (in databasedir)
listdir='lists\'; %%% path to intput files (in maindir)
loadir='loa\'; %%% path to output files (in maindir)

%%% databases
if OPT.knowseas
    scenid='Knowseas';
    netcdfdir=[scenid,'_111121\']; %%% path to nc files
    file_ext='-19770101-20091231';
    dateori=datenum(1970,1,1); %%% time offset in netcdf
elseif OPT.ospar
    scenid='Ospar';
    netcdfdir='Loads_CEFAS_1985_2009\'; %%% path to nc files
    file_ext='_1985_2009';
    dateori=0;
end
file_ext_lake='_Lake_IJssel.txt'; %%% extension lake ijssel

%%% lists (folders, rivers, countries, substances, etc.)
%%%% file names
folderfilename=['listoffolders_',lower(scenid),'.dat'];
riverfilename=['listofrivers_',lower(scenid),'.dat'];
countryfilename=['listofcountries_',lower(scenid),'.dat'];
substancefilename=['listofsubstances_',lower(scenid),'.dat'];

%%%% folders, rivers and countries
cd(maindir); cd(listdir);
listoffolders=textread(folderfilename,'%s');
listofrivers=textread(riverfilename,'%s');
listofcountries=textread(countryfilename,'%s');
listofmysubstances=textread(substancefilename,'%s');

%%%% substances
listofcorrectedsubstances={ ...
    'ammonium','nitrate','phosphate','silicate'}';
listofindices=[ ...
	strmatch('discharge',lower(listofmysubstances)), ...
	strmatch('ammonium',lower(listofmysubstances)), ...
	strmatch('nitrate',lower(listofmysubstances)), ...
	strmatch('phosphate',lower(listofmysubstances)), ...
    strmatch('silicate',lower(listofmysubstances))];

%%%% numbers
nbmysubstances=size(listofmysubstances,1);
nbcorrections=size(listofcorrectedsubstances,1);
nbfolders=size(listoffolders,1);
nbcountries=size(listofcountries,1);
nbyears=size(OPT.years,2);
nbtimes=datenum(OPT.years(end)+1,1,1)-datenum(OPT.years(1),1,1);
if OPT.ospar %%%% REMOVE the condition once databases are consistent
    nbtimes=nbtimes-2;
end

%%%% list of rivers and list of rivers per country
listofmyrivers=[]; listofriverspercountry=cell(nbcountries,1);
indcountry=zeros(nbcountries,1);
for ii=1:nbcountries
    indcountry(ii)= ...
        strmatch(lower(listofcountries{ii}),lower(listofrivers),'exact');
end
dum2=indcountry(2:end)-1; dum2(nbcountries)=size(listofrivers,1);
dum1=indcountry+1; dum=[dum1,dum2];
for ii=1:nbcountries
    listofmyrivers=[listofmyrivers;listofrivers(dum(ii,1):dum(ii,2))];
    listofriverspercountry{ii}=listofrivers(dum(ii,1):dum(ii,2));
end
nbmyrivers=size(listofmyrivers,1);

%%% pre-running checklist
%%%% pre-allocation
data=zeros(nbmyrivers,nbtimes,2,nbmysubstances);
datainfo=cell(nbmyrivers,3);

%%%% error detection
if (OPT.ospar && OPT.knowseas) || (~OPT.ospar && ~OPT.knowseas) || ...
        (nbfolders ~= nbmysubstances)
    error('Error(s) in setting up the script');  
end

%%%% cleaning
clear *filename dum* ind*


%% 2 READ NETCDF FILES
disp('reading netcdf files');
for ii=1:nbmysubstances
    %%% go to the directory containing nc files
    path2nc=[databasedir,netcdfdir,listoffolders{ii},'\'];
    cd(path2nc);
    
    %%% open & read the nc file
    for jj=1:nbmyrivers
        filename=[listofmyrivers{jj},file_ext,'.nc'];
        
        %%% read the data
        data(jj,:,1,ii)=nc_varget(filename,listofmysubstances{ii});
        data(jj,:,2,ii)=nc_varget(filename,'time')+dateori;

        %%% read the meta data
        if OPT.knowseas
            datainfo{jj,1}=nc_varget(filename,'station_id');
        elseif OPT.ospar
            datainfo{jj,1}=listofmyrivers{jj}; %%% different databases formats
        end
        datainfo{jj,2}=nc_varget(filename,'lat')'; %%% optional
        datainfo{jj,3}=nc_varget(filename,'lon')'; %%% optional
    end
end


%% 3 DATA CORRECTIONS AND UNIT CONVERSION
disp('applying corrections and conversion');

%%% corrections for the ospar scenario
if OPT.ospar
for ii=1:nbcorrections
    
    indcorrec=strmatch(lower(listofcorrectedsubstances{ii}), ...
        lower(listofmysubstances),'exact');
    tempdata=data(:,:,1,indcorrec);

    if strcmpi('ammonium',listofcorrectedsubstances{ii}) || ...
        strcmpi('phosphate',listofcorrectedsubstances{ii}) || ...
        strcmpi('silicate',listofcorrectedsubstances{ii})
    
        %%% corrections (NaN)
        cond1=isnan(tempdata) | tempdata<=threshold;
        tempdata(cond1)=limit;
    
        %%% conversion
        convcond=tempdata~=limit;

    elseif strcmpi('nitrate',listofcorrectedsubstances{ii})
        %%% find nitrite
        jj=strmatch('nitrite',lower(listofmysubstances),'exact');
        tempdata2=data(:,:,1,jj);

        %%% corrections (NaN)
        cond1=isnan(tempdata) & isnan(tempdata2);
        cond2=isnan(tempdata) & tempdata2<=threshold;
        cond3=tempdata<=threshold & isnan(tempdata2);
        cond4=tempdata<=threshold & tempdata2<=threshold;

        tempdata(cond1|cond2|cond3|cond4)=limit;
    
        %%% corrections (update)
        conda=isnan(tempdata) & tempdata2~=limit;
        condb=tempdata<=threshold & tempdata2~=limit;
        condc=tempdata~=limit & isnan(tempdata2);
        condd=tempdata~=limit & tempdata2<=threshold;
        conde=tempdata~=limit & tempdata2~=limit & ...
            ~conda & ~condb & ~condc & ~condd;
    
        tempdata(conda|condb)=tempdata2(conda|condb);
        tempdata(conde)=(tempdata(conde)+tempdata2(conde));
   
        %%% conversion
        convcond=tempdata~=limit;
    end
    
    %%% unit conversion
    tempdata(convcond)=tempdata(convcond).*factorconversion;
    
    %%% data correction
    data(:,:,1,indcorrec)=tempdata;
    
    %%% cleaning
    clear tempdata tempdata2 con*
end
end

%%% corrections for the knowseas scenario
if OPT.knowseas
for ii=1:nbcorrections
    
    indcorrec=strmatch(lower(listofcorrectedsubstances{ii}), ...
        lower(listofmysubstances),'exact');
    tempdata=data(:,:,1,indcorrec);

    if strcmpi('ammonium',listofcorrectedsubstances{ii}) 
        %%% corrections (NaN)
        cond1=isnan(tempdata) | tempdata<=threshold;
        tempdata(cond1)=limit;

        %%% conversion
        convcond=tempdata~=limit;
    
    elseif strcmpi('nitrate',listofcorrectedsubstances{ii}) || ...
            strcmpi('phosphate',listofcorrectedsubstances{ii}) || ...
            strcmpi('silicate',listofcorrectedsubstances{ii})

        %%% find relevant complementary substance
        if strcmpi('nitrate',listofcorrectedsubstances{ii})
            jj=strmatch('nitrite',lower(listofmysubstances),'exact');
        elseif strcmpi('phosphate',listofcorrectedsubstances{ii})
            jj=strmatch('totalp',lower(listofmysubstances),'exact');
        elseif strcmpi('silicate',listofcorrectedsubstances{ii})
            jj=strmatch('discharge',lower(listofmysubstances),'exact'); 
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
        conda=isnan(tempdata) & tempdata2~=limit;
        condb=tempdata<=threshold & tempdata2~=limit;
        condc=tempdata~=limit & isnan(tempdata2);
        condd=tempdata~=limit & tempdata2<=threshold;
        conde=tempdata~=limit & tempdata2~=limit & ...
            ~conda & ~condb & ~condc & ~condd;
        %%%% for phosphate only
        condf=conde & tempdata==tempdata2;
        %%%% for silicate only
        condg=isnan(tempdata);
        condh=tempdata<=threshold;
    
        if strcmpi('nitrate',listofcorrectedsubstances{ii})
            %%% corrections
            tempdata(conda|condb)=tempdata2(conda|condb);
            tempdata(conde)=(tempdata(conde)+tempdata2(conde));
            %%% conversion
            convcond=tempdata~=limit;
        elseif strcmpi('phosphate',listofcorrectedsubstances{ii})
            %%% corrections
            tempdata(conda|condb)=tempdata2(conda|condb);
            tempdata2(condf)=1.42.*tempdata(condf)+0.07; %%% Meuwese, 2007
            tempdata(conde)=tempdata(conde)+0.25*(tempdata2(conde)- ...
                tempdata(conde));
            %%% conversion
            convcond=tempdata~=limit;
        elseif strcmpi('silicate',listofcorrectedsubstances{ii})
            %%% corrections
            tempdata(condg|condh)=tempdata2(condg|condh).*10;
            %%% corrections
            convcond=tempdata~=limit & ~condg & ~condh;
        end
    end
    
    %%% unit conversion
    tempdata(convcond)=tempdata(convcond).*factorconversion;
    
    %%% data correction
    data(:,:,1,indcorrec)=tempdata;
    
    %%% cleaning
    clear tempdata tempdata2 con*
end
end


%% 4 WRITING OUTPUT
%%% writing loa files per year
if OPT.loa
disp('writing .loa files');

for ii=1:nbyears
    %%%% new file
    filename=[maindir,loadir,OPT.loaname,num2str(OPT.years(ii)),'.loa'];
    
    %%%% specific case of lake_ijssel
    if OPT.knowseas==1 && OPT.years(ii)>1984
        fsource=[databasedir,lakeijsseldir, ...
            num2str(OPT.years(ii)),file_ext_lake];
        [status,message,messageid]=copyfile(fsource,filename,'f');
    end
    
    %%%% masks of years
    mask_inf=datenum(OPT.years(ii),1,1);
    mask_sup=datenum(OPT.years(ii)+1,1,1);
    
    %%%% all the rivers
    file=fopen(filename,'a+');
    for jj=1:nbmyrivers
        if OPT.years(ii)>1984 && ...
                strcmpi(lower(listofmyrivers{jj}),'lake_ijssel')
        else
    	%%%% apply mask of years to data
        temptime=data(jj,:,2,1)';
        timecond=temptime>=mask_inf & temptime<mask_sup;
        tempdata=data(jj,timecond,1,:);
        nbtimesteps=size(tempdata,2);
        
        %%%% header
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
        
        %%%% data
        for kk=1:nbtimesteps
            fprintf(file,'%i000000 %i 0 %e %e %e %e\n',(kk-1), ...
                tempdata(1,kk,1,listofindices(1)), ... %%% discharge
                tempdata(1,kk,1,listofindices(2)), ... %%% ammmonium
                tempdata(1,kk,1,listofindices(3)), ... %%% nitrate (+nitrite)
                tempdata(1,kk,1,listofindices(4)), ... %%% phosphate
                tempdata(1,kk,1,listofindices(5))); %%% silicate
        end
        clear temdata cond
        end
    end

    %%%% footer (meta-data)
    fprintf(file,'\n');
	fprintf(file,'\n; created by %s %s',name_mscript,versionnr);
	fprintf(file,'\n; NetCDF database: %s%s',databasedir,netcdfdir);
    fprintf(file,'\n\n; Values are expressed in g/s');
	fprintf(file,'\n; if value = NaN or <-1E-05, new value = 1E-10');
	fprintf(file,'\n; Nitrate = Nitrate + Nitrite');
    
    if OPT.knowseas
        fprintf(file,'\n; Silicate=10 x discharge if Silicate=1E-10 and discharge is known');
        fprintf(file,'\n; Phosphate');
        fprintf(file,'\n; - if PO4=NaN or <-1E05, PO4=TotP if TotP is known');
        fprintf(file,'\n; - if TotP=PO4, TotP=1.42.*PO4+0.07 (Meuwese 2007)');
        fprintf(file,'\n;   and PO4=PO4+0.25*(TotP-PO4)');
        fprintf(file,'\n; - for Lake_IJssel, PO4=min(totP,orthoP+(0.9*(algP+detP)))');
    end
    
    fprintf(file,'\n; eof');
    fclose(file);
end

end

%%% writing .loa clone files per year
if OPT.loacountry
disp('writing .loa clone files');
for ll=1:nbcountries
	%%%% number of rivers per country
    listoflocalrivers=listofriverspercountry{ll};
    nblocalrivers=size(listoflocalrivers,1);
    
    for ii=1:nbyears        
        filename=[maindir,loadir,OPT.loaname,num2str(OPT.years(ii)), ...
            '.',upper(listofcountries{ll})];
        
        %%%% specific case of lake_ijssel
%         if OPT.knowseas==1 && OPT.years(ii)>1984 && ...
%                 max(strcmpi(lower(listoflocalrivers),'lake_ijssel'))
%         	fsource=[databasedir,lakeijsseldir, ...
%                     num2str(OPT.years(ii)),file_ext_lake];
%             [status,message,messageid]=copyfile(fsource,filename,'f');
%         end
    
        %%%% mask of years
        mask_inf=datenum(OPT.years(ii),1,1);
        mask_sup=datenum(OPT.years(ii)+1,1,1);
           
        %%%% all the local rivers
        file=fopen(filename,'w+');
        for jj=1:nblocalrivers
            %%%% identify the river
            mm=strmatch(listoflocalrivers{jj},listofmyrivers,'exact');
            
            %%%% apply mask of years to data
            temptime=data(mm,:,2,1)';
            timecond=temptime>=mask_inf & temptime<mask_sup;
            tempdata=data(mm,timecond,1,:);
            nbtimesteps=size(tempdata,2);
            
            %%%% header
            fprintf(file,'ITEM');
            fprintf(file,'\n  ''%s''',datainfo{mm});
            fprintf(file,'\nCONCENTRATIONS');
            fprintf(file,'\n   USEFOR ''NH4-r''    ''new_ammonium''  MIN 0');
            fprintf(file,'\n   USEFOR ''NO3-r''    ''new_nitrate''   MIN 0');
            fprintf(file,'\n   USEFOR ''PO4-r''    ''new_phosphate'' MIN 0');
            fprintf(file,'\nTIME LINEAR');
            fprintf(file,'\nDATA');
            fprintf(file,'\n''new_ammonium''''new_nitrate''''new_phosphate''\n');

            %%%% data
            for kk=1:nbtimesteps
                fprintf(file,'%i000000 %e %e %e\n',(kk-1), ...
                    tempdata(1,kk,1,listofindices(2)), ... %%% ammonium
                    tempdata(1,kk,1,listofindices(3)), ... %%% nitrate (+nitrite)
                    tempdata(1,kk,1,listofindices(4))); %%% phosphate
            end
        end
        
        %%%% footer (meta-data)
        fprintf(file,'\n');
        fprintf(file,'\n; created by %s %s',name_mscript,versionnr);
        fprintf(file,'\n; NetCDF database: %s%s',databasedir,netcdfdir);
        fprintf(file,'\n\n; Values are expressed in g/s');
        fprintf(file,'\n; if value = NaN or <-1E-05, new value = 1E-10');
        fprintf(file,'\n; Nitrate = Nitrate + Nitrite');

        if OPT.knowseas
            fprintf(file,'\n; Silicate=10 x discharge if Silicate=1E-10 and discharge is known');
            fprintf(file,'\n; Phosphate');
            fprintf(file,'\n; - if PO4=NaN or <-1E05, PO4=TotP if TotP is known');
            fprintf(file,'\n; - if TotP=PO4, TotP=1.42.*PO4+0.07 (Meuwese 2007)');
            fprintf(file,'\n;   and PO4=PO4+0.25*(TotP-PO4)');
            %%% NOT INCLUDED YET !
            fprintf(file,'\n; - for Lake_IJssel, PO4=min(totP,orthoP+(0.9*(algP+detP)))');
        end

        fprintf(file,'\n; eof');
        fclose(file);     
    end
end

end


%% 5 FIGURE
% riv='Elbe';
% subs='ammonium';
% 
% hold on
% plot(data(strmatch(riv,listofmyrivers,'exact'),:,2,strmatch(subs,listofmysubstances,'exact')), ...
%      data(strmatch(riv,listofmyrivers,'exact'),:),'k', ...
%      data(strmatch(riv,listofmyrivers,'exact'),:,2,strmatch(subs,listofmysubstances,'exact')), ...
%      data(strmatch(riv,listofmyrivers,'exact'),:,1,strmatch(subs,listofmysubstances,'exact')),'r')

%% 6 CLEANING
cd(localdir);
fprintf('it took %4.2f minutes\n',etime(clock(),start_time)/60);

% clear list* nb*
% eof