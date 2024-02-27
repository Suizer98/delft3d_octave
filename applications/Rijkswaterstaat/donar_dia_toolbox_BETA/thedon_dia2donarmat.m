function thedon_dia2donarmat(OPT)
%thedon_dia2donarmat  Transform DIA file to mat file, loop wrapper for donar_dia2donarMat
%
% The structure is organized by observed parameter.
% thedon_dia2donarmat is a wrapper for donar_dia2donarMat.
%
% Takes ~ 13 minutes for all 3 sensors.
%
% The donarMat structure per year looks like this:
%
%      donarMat = 
%      
%                air_radiance: [1x1 struct]
%                fluorescence: [1x1 struct]
%                      oxygen: [1x1 struct]
%                          ph: [1x1 struct]
%          sea_water_salinity: [1x1 struct]
%                   turbidity: [1x1 struct]
%                conductivity: [1x1 struct]
%              water_radiance: [1x1 struct]
%      
%      donarMat.air_radiance
%      
%                    hdr: [1x1 struct]
%                   data: [27852x7 double]
%          referenceDate: 719529
%             dimensions: {4x2 cell}
%                   name: 'Irradiation_in_uE_in_air'
%          standard_name: 'downwelling_longwave_radiance_in_air'
%          deltares_name: 'air_radiance'
%            variableCol: 5
%      
%      donarMat.air_radiance.hdr
%      
%          WNS: {'7788'}
%          PAR: {'INSLG'  'Instraling'  'J'}
%          CPM: {'80'  'Lucht'}
%          EHD: {'E'  'uE'}
%          HDH: {'NVT'  'Niet van toepassing'}
%          ORG: {'NVT'  'Niet van toepassing'}
%          SGK: {'NVT'}
%          IVS: {'NVT'  'Niet van toepassing'}
%          BTX: {'NVT'  'NVT'  'Niet van toepassing'}
%          BTN: {'Niet van toepassing'}
%          ANI: {'NZXXMTZRWK'  'Dienst Noordzee - afdeling WSM te Rijswijk'}
%          BHI: {'WDZOUTCHEMIE'  'RWS WD - afdeling monitoring en laboratorium te Lelystad'}
%          BMI: {'NZXXMTZRWK'  'Dienst Noordzee - afdeling WSM te Rijswijk'}
%          OGI: {'WDMON_CTD'  'Waterdienst afd. monitoring mbv CTD'}
%          GBD: {'NOORDZE'  'Noordzee  (internationaal)'}
%          LOC: {'NOORDZEW84'  'Noordzeegrid'  'G'  'W84'  '-5000000'  '47000000'}
%          GRD: {'0'}
%          ANA: {'NVT'  'Niet van toepassing'}
%          BEM: {'VELDMTG'  'Veldmeting, directe bepaling in het veld'}
%          BEW: {'NVT'  'Niet van toepassing'}
%          VAT: {'ROSSPR'  'Roset-sampler'}
%          TYP: {'D4'}
%          TYD: {'20070213'  '0736'  '20070213'  '0736'}
%          PLT: {'WATSGL'}
%          SYS: {'CENT'}
%          STA: {'O'}
%          BGS: {'6334679'  '53335821'  '6334679'  '53335821'}
%          
%      donarMat.air_radiance.dimensions
%          
%          'longitude'    'degrees_east'                           
%          'latitude'     'degrees_north'                          
%          'depth'        'centimeters'                            
%          'time'         'days since 1970-Jan-01 00:00:00 UTC + 1    
%
%See also: findAllFiles, donar_dia2donarMat

OPT.diadir = 'p:\1204561-noordzee\data\raw\RWS\';
OPT.diadir = 'p:\1209005-eutrotracks\raw\';
    
%% The location of the raw ".dia" files

diafiles  = findAllFiles(OPT.diadir,'pattern_incl','*.dia');
nfile     = length(diafiles);
for ifile = 1:1:nfile

%% GENERATION OF DONARMAT FILE 
    thefolder = first_subdir(fileparts(diafiles{ifile}),-1); % remove trailing \raw\

    if     strfind(lower(diafiles{ifile}),'ctd')    ;sensor_name = 'CTD'; 
    elseif strfind(lower(diafiles{ifile}),'ferry')  ;sensor_name = 'FerryBox';
    elseif strfind(lower(diafiles{ifile}),'meetvis');sensor_name = 'ScanFish';
    end

    disp(diafiles{ifile});

    % Three inputs: 1. Absolute path to the '.dia' file. (string)
    %               2. Names of columns and corresponding units. The
    %                  units of the variable are taken from the header
    %                  so they are not necessary. (Cell array of
    %                  strings with two columns, column 1 is the name 
    %                  and column 2. is the units.)
    %               3. The timezone. 
    disp(['Processing DONAR dia file ',num2str(ifile),'/',num2str(nfile),': ',diafiles{ifile}])
    thecompend = donar_dia2donarMat( ...
                     diafiles{ifile}, ....
                     {   'longitude'  ,'degrees_east'; ...
                         'latitude'   ,'degrees_north'; ...
                         'depth'      ,'centimeters'; ...
                         'datestring' ,'yyyymmdd';...
                         'timestring' ,'HHMMSS'; ...
                         'variable'   ,'' ...
                     }, ...
                     'UTC + 1' ...
                 );
    disp(['Opening file',char(10)]);


    year_fields = strrep(fields(thecompend),'year','');
    for iyear = 1:1:length(year_fields)

%% Save information with flags, per parameter

        toSave = thecompend.(['year',year_fields{iyear}])
        disp(['Saving: ',thefolder,sensor_name,'_',year_fields{iyear},'_withFlag','.mat']);
        save([thefolder,sensor_name,'_',year_fields{iyear},'_withFlag','.mat'],'toSave');

%% Save only unflagged information, per parameter

        parameter_fields = fields(thecompend.(['year',year_fields{iyear}]));
        for j = 1:length(parameter_fields)

            index = thecompend.(['year',year_fields{iyear}]).(parameter_fields{j}).data(:,7) ~= 0;
                    thecompend.(['year',year_fields{iyear}]).(parameter_fields{j}).data(index,:) = []; % Remove the flagged data... to use in the rest of the scripts
        end
        toSave = thecompend.(['year',year_fields{iyear}]);

        disp(['Saving ',thefolder,sensor_name,'_',year_fields{iyear},'_the_compend','.mat',char(10)]);
        save([          thefolder,sensor_name,'_',year_fields{iyear},'_the_compend','.mat'], 'toSave');

    end

end

