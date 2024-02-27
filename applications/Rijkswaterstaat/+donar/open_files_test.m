%open_files_test test donar.open_file, to test aggregated variables
%
% Test for donar toolbox with novel data from from Rijkswaterstaat ship Zirfaea
%  * CTD     (station,z,t) 1D profiles at series of fixed positions
%  * FerryBox(x,y      ,t) 2D trajectory (fixed z)
%  * MeetVis (x,y    ,z,t) 3D trajectory (undulating z)
%  requested at helpdeskwater.nl
%
% -----+----+------+--------+--------+-----------------------------------------------------------------+---------->
% File |WNS | # of |   # of |   DONAR|                                                              CF | DONAR
% index|code|blocks|  values|    name|                                         standard_name [UDunits] | long_name [EHD]
% -----+----+------+--------+--------+-----------------------------------------------------------------+---------->
%     1|1926|    11|   46414|   INSLG|               downwelling_radiance_in_sea_water [microEinstein] | Irradiation in uE in surface water [uE]
%     2| 209|    11|   69671|     %O2|             fractional_saturation_of_oxygen_in_sea_water [0.01] | Percentage oxygen in % in surface water [%]
%     3|2392|    11|   52981|  GELDHD|                        sea_water_electrical_conductivity [mS/m] | Conductivity in mS/m with respect to 20 degrees celsius in surface water [mS/m]
%     4| 360|    11|  167320|      O2|                mass_concentration_of_oxygen_in_sea_water [mg/l] | Oxygen in mg/l in surface water [mg/l]
%     5| 377|    11|  162096|      pH|                        sea_water_ph_reported_on_total_scale [1] | Acidity in surface water [DIMSLS]
%     6|  44|    11|   81036|       T|                          sea_water_temperature [degree_Celsius] | Temperature in oC in surface water [oC]
%     7|5108|    11|  143827| TROEBHD|                                       sea_water_turbidity [NTU] | Turbidity in NTU in surface water [NTU]
%     8| 555|    11|  166163|FLUORCTE|                                      sea_water_fluorescence [1] | Fluorescence in U in surface water [U]
%     9| 559|    11|  167318|  SALNTT|                                          sea_water_salinity [1] | Salinity in surface water [DIMSLS]
%    10|7647|    11|    2259|  GELSHD|                               speed_of_sound_in_sea_water [m/s] | Speed of sound in m/s in surface water [m/s]
%    11|7788|    11|   46392|   INSLG|            downwelling_longwave_radiance_in_air [microEinstein] | Irradiation in uE in air [uE]
% -----+----+------+--------+--------+-----------------------------------------------------------------+---------->
%
%See also: rws_waterbase

clc;clear all;fclose all;tic;profile on
profile clear

root    = 'x:\D'; % VMware
root    = 'D:\';
basedir = ['p:\1209005-eutrotracks\helpdeskwater_delivery_2013\'];
basedir = [root,'\P\1209005-eutrotracks\helpdeskwater_delivery_2013\'];

E = nc2struct([root,'\opendap.deltares.nl\thredds\dodsC\opendap\rijksoverheid\eez\Exclusieve_Economische_Zone_maart2012.nc']);
L = nc2struct([root,'\opendap.deltares.nl\thredds\dodsC\opendap\deltares\landboundaries\northsea.nc']);
%E = nc2struct(['p:\1209005-eutrotracks\ldb\eez\Exclusieve_Economische_Zone_maart2012.nc']);
%L = nc2struct(['p:\1209005-eutrotracks\ldb\landboundaries\northsea.nc']);

OPT.cache = 1; % donar.open() cache
OPT.read  = 1;
OPT.plot  = 1; % SLOW for trajectories, set 2 for scatter plot
OPT.nc    = 1;
OPT.pause = 0;

dir.raw   = 'raw';
dir.nc    = 'nc';
dir.png   = 'png';
dir.fig   = 'fig';

OPT.sensor.code  = 'meetv'; %'ferry';%'meetv'

switch OPT.sensor.code
% dec 2013 delivery: unzipped to folders below, sorting into ctd;ferry;meetv
case 'ctd',
    diafiles  = {'raw\ctd\ctd_1.dia',... % 02-Jun-1999 02:51:33 - 03:03:19: 1 profile  = 2 dia blocks
                 'raw\ctd\ctd_2.dia',...
                 'raw\ctd\ctd_3.dia',...
                 'raw\ctd\ctd_4.dia',...
                 'raw\ctd\ctd_5.dia',...
                 'raw\ctd\ctd_6.dia',...
                 'raw\ctd\ctd_7.dia',...
                 'raw\ctd\ctd_8.dia'}; 
    type = [3 3 3 3 3 3 3 3]; %[1 1 1 1 1 1 1 1]; % 1=CTD profiles, 2=2Dtrajectory (fixed Z), 3=3Dtrajectory (undulating z)
    OPT.sensor.label = 'ctd';    
case 'ferry',
    diafiles  = {'raw\ferry\ferry_4.dia',... % 02-Jun-1999 02:51:33 - 03:03:19: 1 profile  = 2 dia blocks
                 'raw\ferry\ferry_5.dia',...
             ... 'raw\ferry\ferry_6.dia',... % corrupt
                 'raw\ferry\ferry_7.dia',...
                 'raw\ferry\ferry_8.dia'}; 
    type = [2 2 2 2 2]; % 1=CTD profiles, 2=2Dtrajectory (fixed Z), 3=3Dtrajectory (undulating z)
    OPT.sensor.label = 'ferrybox';
case 'meetv', % issue with z: cm and mm
    diafiles  = {'raw\meetv\meetv_1.dia',... % 02-Jun-1999 02:51:33 - 03:03:19: 1 profile  = 2 dia blocks
                 'raw\meetv\meetv_2.dia',...
                 'raw\meetv\meetv_3.dia',...
                 'raw\meetv\meetv_4.dia',...
                 'raw\meetv\meetv_5.dia',...
                 'raw\meetv\meetv_6.dia',...
                 'raw\meetv\meetv_7.dia'}; 
    type = [3 3 3 3 3 3 3]; % 1=CTD profiles, 2=2Dtrajectory (fixed Z), 3=3Dtrajectory (undulating z)
    OPT.sensor.label = 'scanfish';
otherwise
end

%% open and aggregate files
  [Files,File]    = donar.open_files(cellfun(@(x)[basedir,filesep,x],diafiles,'Uniform',0),'cache',OPT.cache,'disp',1000);
  
  donar.disp(Files)
  
%% loop variables
for ivar = [3:length(Files.Variables)]; % CTD ivar=2(209) too big
    
  if (strcmpi(OPT.sensor.code,'meetv')|strcmpi(OPT.sensor.code,'ctd')) & strcmpi(Files.Variables(ivar).WNS,'209')
      warning('ctd and meetv sweapped for 209')
  end
    
  disp(['Variable: ',num2str(ivar)])

  if OPT.read
     ncolumn = 6; % dia syntax constant
    
        [D,M0] = donar.read(Files,ivar,ncolumn);

        %% convert
        if all(type==1) % each profile_id seems to be in a seperate block": profile_id==block
           [S,M ] = donar.ctd_struct       (D,M0);%save('ctd.mat','-struct','S')
        else
           [S,M ] = donar.trajectory_struct(D,M0);%save('trajectory.mat','-struct','S')
        end
        
        %% make netCDF file per station: they are disconnected anyway:
        %  only taken when boat does not move (unlike Ferrybox)

        if all(type==1)
        
          %% plot overview   
          file.png = [basedir,filesep,dir.png,filesep,OPT.sensor.code,filesep,OPT.sensor.label,'_',M.data.deltares_name,'_overview.png'];
          close all % to avoid memory crash
          donar.ctd_overview_plot(S,M,E,L)
          print2a4(file.png,'v','t',200,'o')
          close % remove colormap

          %% proces per location
          for ist=1:length(S.station_lon)
            
             file.nc  = [basedir,filesep,dir.nc ,filesep,OPT.sensor.code,filesep,OPT.sensor.label,'_',M.data.deltares_name,filesep,OPT.sensor.label,'_',M.data.deltares_name,'_',num2str(ist,'%0.3d'),'.nc' ];
             file.png = [basedir,filesep,dir.png,filesep,OPT.sensor.code,filesep,OPT.sensor.label,'_',M.data.deltares_name,filesep,OPT.sensor.label,'_',M.data.deltares_name,'_',num2str(ist,'%0.3d'),'.png'];

             disp(['processing ctd ',num2str(ist),'/',num2str(length(S.station_lon))])
             ind = (S.station_id==ist);
             clear P
             P = donar.ctd_timeSeriesProfile(S,ind);
             if OPT.nc;donar.ctd_timeSeriesProfile2nc(file.nc,P,M);end
           %[P2,M2] = nc2struct(file.nc,'rename',{{donar.resolve_wns(M.data.WNS)},{'data'}});
             if OPT.plot>0 % per timeseries-profile
                titletxt = [num2str(S.station_n(ist)),' points over ',num2str(length(P.profile_datenum)),' profiles ',num2strll(S.station_lat(ist),S.station_lon(ist))];

                close all % to avoid memory crash
                donar.ctd_timeSeriesProfile_plot(P,E,L,titletxt,'colorfield','z','colorlabel','z [cm]')
                print2a4(strrep(file.png,M.data.deltares_name,[M.data.deltares_name,'_z']),'v','t',200,'o')

                clf
                donar.ctd_timeSeriesProfile_plot(P,E,L,titletxt,'colorfield','data','colorlabel',mktex([M.data.long_name,'[',M.data.units,']']),'clims',donar.resolve_clim(M.data.WNS));
                print2a4(file.png,'v','t',200,'o')
                close

             end % plot
          end % ist

        elseif all(type==2) | all(type==3)
        
            file.nc  = [basedir,filesep,dir.nc ,filesep,OPT.sensor.code,filesep,OPT.sensor.label,'_',M.data.deltares_name,'.nc' ];
            file.png = [basedir,filesep,dir.png,filesep,OPT.sensor.code,filesep,OPT.sensor.label,'_',M.data.deltares_name];
            file.fig = [basedir,filesep,dir.fig,filesep,OPT.sensor.code,filesep,OPT.sensor.label,'_',M.data.deltares_name];
            
            if strcmpi(OPT.sensor.code,'ferry') & all(type==2) % FerryBox: remove error values
               S.z(~(S.z==300))=nan; 
            end

            if OPT.nc;donar.trajectory2nc(file.nc,S,M);end
           %[S2,M2] =  nc2struct(strrep(diafile,'.dia',['_',M.data.deltares_name,'_ferrybox.nc' ]),'rename',{{M.data.deltares_name},{'data'}});
            if OPT.plot>0
            close all % to avoid memory crash
            donar.trajectory_overview_plot(S,M,E,L,...
                'clims',donar.resolve_clim(M.data.WNS),...
                'titletxt',[File.Variables(ivar).hdr.OGI{2}],...
                'scatter',OPT.plot>1)
            print2screensizeoverwrite(file.png)
            %saveas(gcf,file.fig); % matlab is terrible at rendering scatter
            end           
        end
        
        if OPT.pause
           pausedisp
        end
        
  end % read
  
end % variables    
