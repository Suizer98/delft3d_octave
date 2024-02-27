%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18457 $
%$Date: 2022-10-17 20:32:45 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: labels4all.m 18457 2022-10-17 12:32:45Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/labels4all.m $
%
%labels
%
%INPUT
%   -var: variable to generate label
%       -'eta'       : elevation
%
%       -'etab'      : bed elevation
%       -'detab'     : bed elevation change
%       -'detab_ds'  : bed slope
%
%       -'dist'      : distance
%       -'dist_prof' : distance along section
%       -'dist_mouth': distance from mouth
%
%       -{'etaw','WATHTE'}     : water level
%       -'h'        : flow depth
%
%       -'sal'      : salinity [psu]
%       -{'cl','CONCTTE'}       : chloride [mg/l]
%       -'salm2'    : mass of salt per unit surface [kg/m^2]
%       -'cl_surf'  : surface chloride [mg/l]
%       -'cl_bottom': bottom chloride [mg/l]
%       -'sal_mass' : mass of salt [kg]
%       -'cl_mass'  : mass of salt [kg]
%       -'sal_t'    : mass of salt per unit time [kg/s]
%       -'cl_t'     : mass of salt per unit time [kg/s]
%
%       -'umag'     : velocity magnitude
%
%       -'x'        : x-coordinate
%       -'y'        : y-coordinate
%
%       -{'Q','qsp_B'}  : water discharge
%       -'Qcum'         : cumulative water discharge
%       -'qsp'          : specific water discharge
%       -'qxsp'         : specific water discharge in x direction
%       -'qysp'         : specific water discharge in y direction
%
%       -{'Q_t','qsp_B_t'}  : volume of water
%
%       -'stot'       : total sediment transport [m^2/s]
%       -'stot_B_mor' : total sediment transport [m^3/s]
%       -'stot_B_mor_t' : total sediment transport [m^3]
%
%       -'tide'     : tide
%       -'surge'    : surge
%
%       -'t'        : time
%       -'tshift'   : time shift
%
%       -'corr'     : correlation coefficient
%
%       -{'dd','wind_dir'}  : wind direction
%       -{'fh','wind_u'}    : wind speed
%
%       -'simulation' : simulation
%       -'measurement': measurment
%       -'mea'      : measured
%       -'sim'      : computed
%
%       -'original' : original
%       -'modified' : modified
%
%       -'dg'       : geometric mean grain size
%       -'dm'       : arithmetic mean grain size
%       -'d10'      : 
%       -'d50'      : 
%       -'d90'      : 
%
%       -'vicouv'   : horizontal viscosity
%
%       -'at'       : at
%
%       -'La'       : active layer
%       -'Fak'      : volume fraction content in the active layer
%       -'mesh2d_taus' : bed shear stress
%       -'mesh2d_taus_t' : integral bed shear stress with time
%
%       -'rkm'      : river kilometer
%
%       -'ba_mor'   : morphodynamic cell area
%
%       -'sb'       : bed load sediment transport
%
%       -'T_surf'   :
%       -'T_da'     :
%       -'T_max'    :
%
%
%
%   -un: factor for unit conversion from SI
%
%   -lan: language
%       -'en': english
%       -'nl': dutch
%       -'es': spanish

function [lab,str_var,str_un,str_diff,str_background,str_std,str_diff_back,str_fil]=labels4all(variable,un,lan,varargin)

%%

parin=inputParser;

addOptional(parin,'Lref','+NAP');
addOptional(parin,'frac',1);

parse(parin,varargin{:});

Lref=parin.Results.Lref;
frac=parin.Results.frac;

%%

switch lower(variable)
    case 'eta'
        switch lan
            case 'en'
                str_var='elevation';
            case 'nl'
                str_var='hoogte';
            case 'es'
                str_var='elevación';
        end
        un_type='Lref';
    case {'etab','mesh2d_mor_bl','dps','bl'}
        switch lan
            case 'en'
                str_var='bed elevation';
            case 'nl'
                str_var='bodemhoogte';
            case 'es'
                str_var='elevación del lecho';
        end
        un_type='Lref';
    case {'detab'}
        switch lan
            case 'en'
                str_var='bed elevation change';
            case 'nl'
                str_var='bodemverandering';
            case 'es'
                str_var='cambio en la elevación del lecho';
        end
        un_type='L';
    case {'detab_ds'}
        switch lan
            case 'en'
                str_var='bed slope';
            case 'nl'
                str_var='bodemverhang';
            case 'es'
                str_var='pendiente del lecho';
        end
        un_type='-';
    case 'dist'
        switch lan
            case 'en'
                str_var='distance';
            case 'nl'
                str_var='afstand';
            case 'es'
                str_var='distancia';
        end
        un_type='L'; 
    case 'dist_prof'
        switch lan
            case 'en'
                str_var='distance along section';
            case 'nl'
                str_var='afstand langs gevaren track';
            case 'es'
                str_var='distancia a lo largo de la sección';
        end
        un_type='L'; 
    case 'dist_mouth'
        switch lan
            case 'en'
                str_var='distance from mouth';
            case 'nl'
                str_var='afstand van de riviermonding';
            case 'es'
                str_var='distancia a la desembocadura';
        end
        un_type='L'; 
    case {'etaw','waterlevel','wathte','mesh2d_s1','wl'}
        switch lan
            case 'en'
                str_var='Water level';
            case 'nl'
                str_var='Waterstand';
            case 'es'
                str_var='Nivel del agua';
        end
        un_type='Lref'; 
     case 'tide'
        switch lan
            case 'en'
                str_var='Tide';
            case 'nl'
                str_var='Getij';
            case 'es'
                str_var='Marea';
        end
        un_type='L'; 
    case 'surge'
        switch lan
            case 'en'
                str_var='Surge';
            case 'nl'
                str_var='Opzet';
            case 'es'
                str_var='marejada ciclónica';
        end
        un_type='L';
    case 'plotted period'
        switch lan
            case 'en'
                str_var='plotted period';
            case 'nl'
                str_var='weegegeven periode';
            case 'es'
                str_var='período trazado';
        end
        un_type='-';
    case 'entire period'
        switch lan
            case 'en'
                str_var='entire period';
            case 'nl'
                str_var='gehele periode';
            case 'es'
                str_var='todo el período';
        end
        un_type='-';
    case {'h','mesh2d_waterdepth'}
        switch lan
            case 'en'
                str_var='depth';
            case 'nl'
                str_var='diepte';
            case 'es'
                str_var='profundidad';
        end
        un_type='L';
    case {'sal'}
        switch lan
            case 'en'
                str_var='salinity';
            case 'nl'
                str_var='saliniteit';
            case 'es'
                str_var='salinidad';
        end
        un_type='-';
    case {'cl','conctte'}
        switch lan
            case 'en'
                str_var='chloride';
            case 'nl'
                str_var='chloride';
            case 'es'
                str_var='cloruro';
        end
        un_type='-';
    case {'cl_surf'}
        switch lan
            case 'en'
                str_var='surface chloride';
            case 'nl'
                str_var='chloride aan wateroppervlak';
            case 'es'
                str_var='cloruro en la superficie';
        end
        un_type='-';
    case {'cl_bottom'}
        switch lan
            case 'en'
                str_var='bottom chloride';
            case 'nl'
                str_var='chloride aan bodem';
            case 'es'
                str_var='cloruro en el lecho';
        end
        un_type='-';
    case {'salm2'}
        switch lan
            case 'en'
                str_var='salt';
            case 'nl'
                str_var='zout';
            case 'es'
                str_var='sal';
        end
        un_type='M/L2';
    case {'sal_mass'}
        switch lan
            case 'en'
                str_var='salt';
            case 'nl'
                str_var='zout';
            case 'es'
                str_var='sal';
        end
        un_type='M';
    case {'cl_mass'}
        switch lan
            case 'en'
                str_var='chloride';
            case 'nl'
                str_var='chloride';
            case 'es'
                str_var='cloro';
        end
        un_type='M';
    case {'sal_t'}
        switch lan
            case 'en'
                str_var='salt';
            case 'nl'
                str_var='zout';
            case 'es'
                str_var='sal';
        end
        un_type='M/T';
    case {'cl_t'}
        switch lan
            case 'en'
                str_var='chloride';
            case 'nl'
                str_var='chloride';
            case 'es'
                str_var='cloro';
        end
        un_type='M/T';
    case {'clm2'}
        switch lan
            case 'en'
                str_var='chloride';
            case 'nl'
                str_var='chloride';
            case 'es'
                str_var='cloro';
        end
        un_type='M/L2';
    case {'umag', 'mesh2d_ucmag','velocity_magnitude','ucmag'}
        switch lan
            case 'en'
                str_var='velocity magnitude';
            case 'nl'
                str_var='snelheidsgrootte';
            case 'es'
                str_var='magnitud de la velocidad';
        end
        un_type='L/T';
    case 'un'
        switch lan
            case 'en'
                str_var='cross-wise velocity';
            case 'nl'
                str_var='dwarssnelheid';
            case 'es'
                str_var='velocidad transversal';
        end
        un_type='L/T';
    case 'us'
        switch lan
            case 'en'
                str_var='longitudinal velocity';
            case 'nl'
                str_var='longitudinale snelheid';
            case 'es'
                str_var='velocidad longitudinal';
        end
        un_type='L/T';
    case 'uz'
        switch lan
            case 'en'
                str_var='vertical velocity';
            case 'nl'
                str_var='verticale snelheid';
            case 'es'
                str_var='velocidad vertical';
        end
        un_type='L/T';
    case 'x'
        switch lan
            case 'en'
                str_var='x-coordinate';
            case 'nl'
                str_var='x-coordinaat';
            case 'es'
                str_var='coordenada x';
        end
        un_type='L';
    case 'y'
        switch lan
            case 'en'
                str_var='y-coordinate';
            case 'nl'
                str_var='y-coordinaat';
            case 'es'
                str_var='coordenada y';
        end
        un_type='L';
    case 'simulation'
        switch lan
            case 'en'
                str_var='Simulation';
            case 'nl'
                str_var='Berekening';
            case 'es'
                str_var='Simulación';
        end
        un_type='-';
    case 'measurement'
         switch lan
            case 'en'
                str_var='Measurement';
            case 'nl'
                str_var='Meting';
            case 'es'
                str_var='Medición';
         end
         un_type='-';
    case 'original'
         switch lan
            case 'en'
                str_var='original';
            case 'nl'
                str_var='origineel';
            case 'es'
                str_var='original';
         end
         un_type='-';
    case 'modified'
         switch lan
            case 'en'
                str_var='modified';
            case 'nl'
                str_var='gewijzigd';
            case 'es'
                str_var='modificado';
         end
         un_type='-';
     case 'difference'
         switch lan
            case 'en'
                str_var='Difference';
            case 'nl'
                str_var='Verschil';
            case 'es'
                str_var='Diferencia';
         end
         un_type='-';
     case {'q','qsp_b'}
         switch lan
            case 'en'
                str_var='discharge';
            case 'nl'
                str_var='afvoer';
            case 'es'
                str_var='caudal';
         end
         un_type='L3/T';
     case 'qcum'
         switch lan
            case 'en'
                str_var='cumulative discharge';
            case 'nl'
                str_var='cumulatieve afvoer';
            case 'es'
                str_var='caudal acumulado';
         end
         un_type='L3/T';
     case 'qsp'
         switch lan
            case 'en'
                str_var='specific discharge';
            case 'nl'
                str_var='specifieke afvoer';
            case 'es'
                str_var='caudal específico';
         end
         un_type='L2/T';
     case 'qxsp'
         switch lan
            case 'en'
                str_var='x-specific discharge';
            case 'nl'
                str_var='x-specifieke afvoer';
            case 'es'
                str_var='caudal específico x';
         end
         un_type='L2/T';
     case 'qysp'
         switch lan
            case 'en'
                str_var='y-specific discharge';
            case 'nl'
                str_var='y-specifieke afvoer';
            case 'es'
                str_var='caudal específico y';
         end
         un_type='L2/T';
%%
     case 't'
         switch lan
            case 'en'
                str_var='time';
            case 'nl'
                str_var='tijd';
            case 'es'
                str_var='tiempo';
         end
         un_type='T';
    case 'tshift'
         switch lan
            case 'en'
                str_var='time shift';
            case 'nl'
                str_var='tijdsverschuiving';
            case 'es'
                str_var='diferencia de tiempo';
         end
         un_type='-';
%%
    case 'corr'
         switch lan
            case 'en'
                str_var='correlation coefficient';
            case 'nl'
                str_var='correlatiecoëfficiënt';
            case 'es'
                str_var='coeficiente de correlación';
         end
         un_type='-';
    case {'dd','wind_dir'}
         switch lan
            case 'en'
                str_var='wind direction';
            case 'nl'
                str_var='windrichting';
            case 'es'
                str_var='dirección del viento';
         end
         un_type='degrees';
    case {'fh','wind_u'}
         switch lan
            case 'en'
                str_var='wind speed';
            case 'nl'
                str_var='windsnelheid';
            case 'es'
                str_var='velocidad del viento';
         end
         un_type='L/T';
    case 'mea'
         switch lan
            case 'en'
                str_var='measured';
            case 'nl'
                str_var='gemeten';
            case 'es'
                str_var='medido';
         end
         un_type='-';
    case 'sim'
         switch lan
            case 'en'
                str_var='computed';
            case 'nl'
                str_var='berekend';
            case 'es'
                str_var='computado';
         end
         un_type='-';
    case {'dg','mesh2d_dg','dg_la'}
         switch lan
            case 'en'
                str_var='geometric mean grain size';
            case 'nl'
                str_var='geometrische gemiddelde korrelgrootte';
            case 'es'
                str_var='media geométrica del tamaño de grano';
         end
         un_type='L';
    case {'dm','mesh2d_dm'}
         switch lan
            case 'en'
                str_var='arithmetic mean grain size';
            case 'nl'
                str_var='rekenkundig gemiddelde korrelgrootte';
            case 'es'
                str_var='media aritmética del tamaño de grano';
         end
         un_type='L';
    case 'd10'
         switch lan
            case 'en'
                str_var='d_{10}';
            case 'nl'
                str_var='d_{10}';
            case 'es'
                str_var='d_{10}';
         end
         un_type='L';
    case 'd50'
         switch lan
            case 'en'
                str_var='d_{50}';
            case 'nl'
                str_var='d_{50}';
            case 'es'
                str_var='d_{50}';
         end
         un_type='L';
    case 'd90'
         switch lan
            case 'en'
                str_var='d_{90}';
            case 'nl'
                str_var='d_{90}';
            case 'es'
                str_var='d_{90}';
         end
         un_type='L';
    case {'vicouv'}
         switch lan
            case 'en'
                str_var='horizontal eddy viscosity';
            case 'nl'
                str_var='horizontale viscositeit';
            case 'es'
                str_var='viscosidad de turbulencia horizontal';
         end
         un_type='L2/T';
    case {'dicouv','water_dispersion'}
         switch lan
            case 'en'
                str_var='horizontal diffusivity';
            case 'nl'
                str_var='horizontale diffusie';
            case 'es'
                str_var='difusividad horizontal';
         end
         un_type='L2/T';
    case 'at'
         switch lan
            case 'en'
                str_var='at';
            case 'nl'
                str_var='te';
            case 'es'
                str_var='en';
         end
         un_type='-';
    case 'la'
         switch lan
            case 'en'
                str_var='active layer thickness';
            case 'nl'
                str_var='active laag';
            case 'es'
                str_var='capa activa';
         end
         un_type='L';
    case 'fak'
         switch lan
            case 'en'
                str_var=sprintf('volume fraction content of size fraction %d in active layer',frac);
            case 'nl'
                error('do')
%                 str_var='active laag';
            case 'es'
                error('do')
%                 str_var='capa activa';
         end
         un_type='L';

    case {'mesh2d_taus','taus'}
         switch lan
            case 'en'
                str_var='bed shear stress';
            case 'nl'
                str_var='bed schuifspanning';
            case 'es'
                str_var='tensión de fondo';
         end
         un_type='M/T2/L';
    case {'mesh2d_taus_t','taus_t'}
         switch lan
            case 'en'
                str_var='bed shear stress time';
            case 'nl'
                str_var='bed schuifspanning tijd';
            case 'es'
                str_var='tensión de fondo y tiempo';
         end
         un_type='M/T/L';
    case 'ltot'
         switch lan
            case 'en'
                str_var='sediment thickness';
            case 'nl'
                str_var='sediment laag';
            case 'es'
                str_var='capa de sedimento';
         end
         un_type='L';
    case {'sbtot','sb'}
         switch lan
            case 'en'
                str_var='bedload sediment transport';
            case 'nl'
                str_var='bedload sedimenttransport';
            case 'es'
                str_var='transporte de sedimento de fondo';
         end
         un_type='L2/T';
    case 'stot'
         switch lan
            case 'en'
                str_var='total sediment transport';
            case 'nl'
                str_var='totaal sedimenttransport';
            case 'es'
                str_var='transporte de sedimento total';
         end
         un_type='L2/T';
    case 'stot_b_mor'
         switch lan
            case 'en'
                str_var='total sediment transport';
            case 'nl'
                str_var='totaal sedimenttransport';
            case 'es'
                str_var='transporte de sedimento total';
         end
         un_type='L3/T';
    case 'stot_b_mor_t'
         switch lan
            case 'en'
                str_var='total sediment transport';
            case 'nl'
                str_var='totaal sedimenttransport';
            case 'es'
                str_var='transporte de sedimento total';
         end
         un_type='L3';
    case {'q_t','qsp_b_t'}
         switch lan
            case 'en'
                str_var='water volume';
            case 'nl'
                str_var='watervolume';
            case 'es'
                str_var='volumen de agua';
         end
         un_type='L3';
    case {'mesh2d_czs','czs'}
         switch lan
            case 'en'
                str_var='Chézy friction coefficient';
            case 'nl'
                str_var='Chézy wrijvingscoëfficiënt';
            case 'es'
                str_var='Coeficiente de fricción de Chézy';
         end
         un_type='L/T1/2';
    case 'rkm'
         switch lan
            case 'en'
                str_var='river kilometer';
            case 'nl'
                str_var='rivierkilometer';
            case 'es'
                str_var='kilómetro del río';
         end
         un_type='L';
    case 'ba_mor'
         switch lan
            case 'en'
                str_var='morphodynamic cell area';
            case 'nl'
                str_var='morfodynamisch celgebied';
            case 'es'
                str_var='área morfodinámica';
         end
         un_type='L2';
    case 't_da'
         switch lan
            case 'en'
                str_var='depth-average residence time';
            case 'nl'
                str_var='dieptegemiddelde leeftijd';
            case 'es'
                str_var='?';
         end
         un_type='T';
    case 't_surf'
         switch lan
            case 'en'
                str_var='surface residence time';
            case 'nl'
                str_var='oppervlakte leeftijd';
            case 'es'
                str_var='?';
         end
         un_type='T';
    case 't_max'
         switch lan
            case 'en'
                str_var='maximum residence time';
            case 'nl'
                str_var='maximale leeftijd';
            case 'es'
                str_var='?';
         end
         un_type='T';
    otherwise
        str_var=variable;
        un_type='?';
        messageOut(NaN,sprintf('Add variable %s',variable));
%          error('this is missing')
end %var

%% UNIT

str_un=str_unit(un_type,un,lan,Lref,variable);
        
%% LABEL 

lab=strcat(str_var,str_un);

%string unit no ref
switch un_type
    case 'Lref'
        str_un_nr=str_unit('L',un,lan,Lref,variable);
    otherwise
        str_un_nr=str_un;
end
 
%difference
switch lan
    case 'en'
        str_d='difference in';
    case 'nl'
        str_d='verschil in';
    case 'es'
        str_d='diferencia de';
end
str_diff=sprintf('%s %s%s',str_d,str_var,str_un_nr);

%background
 switch lan
    case 'en'
        str_b='above background';
    case 'nl'
        str_b='boven achtergrond';
    case 'es'
        str_b='sobre ambiente';
 end
str_background=sprintf('%s %s%s',str_var,str_b,str_un);

%standard deviation
 switch lan
    case 'en'
        str_s='standard deviation';
    case 'nl'
        str_s='standaardafwijking';
    case 'es'
        str_s='desviación estándar';
 end
str_std=sprintf('%s %s%s',str_s,str_var,str_un_nr);

 %difference above background
str_diff_back=sprintf('%s %s %s%s',str_d,str_var,str_b,str_un_nr);

 %filtered
 switch lan
    case 'en'
        str_f='filtered';
    case 'nl'
        str_f='gefilterd';
    case 'es'
        str_f='filtrado de';
 end
str_fil=sprintf('%s %s %s',str_f,str_var,str_un_nr);

end %function

%%
%% FUNCTIONS
%% 

%%

function str_un=str_unit(un_type,un,lan,Lref,val)

switch un_type
    case 'Lref'
        switch un
            case 1
                str_un=sprintf(' [m%s]',Lref);
            case 1/1000
                str_un=' [km]';
            otherwise
                error('this factor is missing')
        end
    case 'L'
        switch un
            case 1
                str_un=' [m]';
            case 1/1000
                str_un=' [km]';
            otherwise
                error('this factor is missing')
        end
    case 'L3/T'
        switch un
            case 1
                str_un=' [m^3/s]';
%             case 1/1000
%                 str_un=' [km]';
            otherwise
                error('this factor is missing')
        end
    case 'L3'
        switch un
            case 1
                str_un=' [m^3]';
%             case 1/1000
%                 str_un=' [km]';
            otherwise
                error('this factor is missing')
        end
    case '-'
        switch lower(val)
            case 'sal'
                str_un=' [psu]';
            case {'cl','conctte','cl_surf','cl_bottom'}
                str_un= ' [mg/l]'; 
            case {'detab_ds'}
                str_un= ' [-]'; 
            otherwise
                str_un = '';
        end
    case 'L/T'
        switch un
            case 1
                str_un=' [m/s]';
            otherwise
                error('this factor is missing')
        end
    case 'T'
        switch un
            case 1
                str_un=' [s]';
            case 1/60
                str_un=' [min]';
            case 1/3600
                str_un=' [h]';
            case 1/3600/24
                switch lan
                    case 'en'
                        str_un=' [day]';
                    case 'nl'
                        str_un=' [dag]';
                end
            case 1/3600/24/365
                switch lan
                    case 'en'
                        str_un=' [year]';
                    case 'nl'
                        str_un=' [jaar]';
                end
            otherwise
                error('this factor is missing')
        end
    case 'L2/T'
        switch un
            case 1
                str_un=' [m^2/s]';
            otherwise
                error('this factor is missing')
        end
    case 'degrees'
        switch un
            case 1
                str_un=' [º N]';
            otherwise 
                error('this factor is missing')
        end
    case 'M/L2'
        switch un
            case 1
                str_un=' [kg/m^2]';
            otherwise
                error('this factor is missing')
        end
    case 'M'
        switch un
            case 1
                str_un=' [kg]';
            otherwise
                error('this factor is missing')
        end
    case 'M/T'
        switch un
            case 1
                str_un=' [kg/s]';
            otherwise
                error('this factor is missing')
        end
    case 'M/T2/L'
        switch un
            case 1
                str_un=' [Pa]';
            otherwise
                error('this factor is missing')
        end
    case 'L/T1/2'
        switch un
            case 1
                str_un=' [m/s^{1/2}]';
            otherwise
                error('this factor is missing')
        end
    case 'L2'
        switch un
            case 1
                str_un=' [m^2]';
            otherwise
                error('this factor is missing')
        end
    case 'M/T/L'
        switch un
            case 1
                str_un=' [Pa s]';
            otherwise
                error('this factor is missing')
        end
    case '?'
        str_un=' [?]';
    otherwise
        error('This unit is missing')
end %un_type

end %function