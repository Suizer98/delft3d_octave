function varargout = analyseHis(varargin)
%analyseHis   analyse waterlevel time series against OPeNDAP data in time and frequency domain
%
%    dflowfm.analyseHis(<ncfile>,<keyword,value>)
%
% * For Delft3D-flow the trih history file can be converted to netCDF
%   with VS_TRIH2NC such that dflowfm.analyseHis also works on it.
% * For dflowfm.analyseHis to be able to detect associated data
%   automatically, the observation points names have to be 
%   generated with dflowfm.opendap2obs or delft3d_opendap2obs.
%
% Example: dflowfm, using a local cache of netCDF files
%          You can create such a local cache with opendap_get_cache
%
%    platform_data_url = 'F:\opendap\thredds\rijkswaterstaat/waterbase/sea_surface_height'
%    epsg             = 28992
%
%    dflowfm.delft3d_opendap2obs(platform_data_url,...
%                          'epsg', epsg,...
%                          'file',['F:\delft3dfm\run01\rijkswaterstaat_waterbase_sea_surface_height_',num2str(epsg),'.obs'])
%    % ~ run model ~
%         dflowfm.analyseHis('nc','F:\delft3dfm\run01\trih-s01.nc',...
%                       'datelim',datenum(1998,[1 5],[1 28]),...
%             'platform_data_url',platform_data_url,...
%                            'vc','F:\opendap\thredds\noaa/gshhs/gshhs_i.nc')
%
% Example: Delft3D-flow, using a local cache of netCDF files, making monthly plots
%
%    platform_data_url = 'F:\opendap\thredds\rijkswaterstaat/waterbase/sea_surface_height'
%    epsg   = 28992
%
%    delft3d_opendap2obs(platform_data_url,...
%                          'epsg', epsg,...
%                          'file',['F:\delft3dfm\run01\rijkswaterstaat_waterbase_sea_surface_height_',num2str(epsg),'.obs'],...
%                           'grd', 'F:\delft3dfm\run01\wadden4.grd',...
%                          'plot', 1)
%    % ~ run model ~
%         vs_trih2nc('F:\delft3dfm\run01\trih-s01.dat',...
%                          'epsg',epsg)
%         for m=1:12
%         dflowfm.analyseHis('F:\delft3dfm\run01\trih-s01.nc,...
%                       'datelim',datenum(1998,[m m+1],1),...
%                       'datestr','mmm-dd',...
%             'platform_data_url',platform_data_url,...
%                            'vc','F:\opendap\thredds\noaa/gshhs/gshhs_i.nc',...
%                        't_tide',0)
%         end
%
%See also: dflowfm, NC_T_TIDE_COMPARE, T_TIDE2NC, delft3d, OPENDAP_GET_CACHE, 
%          nc2struct, dflowfm.indexHis, vs_trih2nc

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Gerben de Boer / <g.j.deboer@deltares.nl>
%
%       Deltares / P.O. Box 177 / 2600 MH Delft / The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id: analyseHis.m 12974 2016-11-04 14:58:18Z belisats.x.1 $
% $Date: 2016-11-04 22:58:18 +0800 (Fri, 04 Nov 2016) $
% $Author: belisats.x.1 $
% $Revision: 12974 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/+dflowfm/analyseHis.m $
% $Keywords: $

   OPT.nc             = ''; % model netcdf file
   if odd(nargin)
      OPT.nc   = varargin{1};
      varargin = {varargin{2:end}};
   end
   OPT.datelim          = [];
   OPT.datestr          = 'mmm'; % for timeaxis
   OPT.datefmt          = 'yyyy-mm-dd'; %  make empty if you do not want date in filename
   OPT.t_tide           = 1;
   OPT.label            = '';
   OPT.platform_name     = {}; % platform_name of platforms to include
   OPT.platform_data_url = ''; % data netcdf files: char=(opendap) directory, or cellstr()
   OPT.platform_period   = {}; % & associated periods
   OPT.units            = [];
   OPT.timezone         = '+00:00'; % common time zone for data and model comparison in plots
   OPT.model_timezone   = []; % time zone of model is not present in model output (model is not time zone aware)
   OPT.standard_name    = 'sea_surface_height';

   OPT.pause             = 0;
   OPT.plot.planview     = 1;
   OPT.plot.scatter      = 1;
   OPT.plot.planview     = 1;
   OPT.platform_match    = 'exact'; % in order not to find identical names with prefixes and post fixes
   OPT.axis              = [4.4000    6.4000   52.7000   53.6000];
   OPT.vc                = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland.nc';
   OPT.vc                = 'http://opendap.deltares.nl/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc';
   
   
   OPT.platform_data_url = 'http://opendap.deltares.nl/thredds/dodsC/opendap\rijkswaterstaat/waterbase/sea_surface_height';
   OPT.ylim              = [-10 10];
   OPT.varname           = ''; % name of data in data and in internal struct
   OPT.hisname           = '';         % name of data in model output
   OPT.hisnamename       = 'platform_name';      % name of platformnames in model output
   OPT.hislatname        = nan;
   OPT.hislonname        = nan;
   OPT.standard_name     = '';
   OPT.tex_name          = '';
   OPT.code_name         = '';
   OPT.linestyle         = '-'; % 4 data
   
   OPT = setproperty(OPT,varargin); % 1/2
   
switch OPT.standard_name
case 'sea_surface_height'
   OPT.platform_data_url = 'http://opendap.deltares.nl/thredds/dodsC/opendap\rijkswaterstaat/waterbase/sea_surface_height';
   OPT.ylim              = [-2 2.5];
   OPT.varname           = 'sea_surface_height'; % name of data in data and in internal struct
   OPT.hisname           = 'waterlevel';         % name of data in model output
   OPT.standard_name     = 'sea_surface_height';
   OPT.tex_name          = '\eta';
   OPT.code_name         = 'z';

case 'water_volume_transport_into_sea_water_from_rivers'
   OPT.platform_data_url = 'http://opendap.deltares.nl/thredds/dodsC/opendap\rijkswaterstaat/waterbase/water_volume_transport_into_sea_water_from_rivers';
   OPT.ylim              = [-2 2].*1e5;
   OPT.varname           = 'Q';                       % name of data in data and in data and in internal struct
   OPT.standard_name     = 'Q';
   OPT.tex_name          = 'discharge';
   OPT.code_name         = 'Q';
   
   OPT.hisname           = 'cross_section_discharge'; % name of data in model output
   OPT.hisnamename       = 'cross_section_name';	     % name of platformnames in model output
   
case 'sea_water_salinity'
   OPT.platform_data_url = 'http://opendap.deltares.nl/thredds/dodsC/opendap\rijkswaterstaat/waterbase/sea_water_salinity';
   OPT.ylim              = [-5 35]; % -5 for difference plot
   OPT.varname           = 'sea_water_salinity'; % name of data in data and in data and in internal struct
   OPT.hisname           = 'salinity';           % name of data in model output
   OPT.standard_name     = 'sea_water_salinity';
   OPT.tex_name          = 'salinity';
   OPT.code_name         = 'S';
   
case 'sea_water_temperature'
   OPT.platform_data_url = 'http://opendap.deltares.nl/thredds/dodsC/opendap\rijkswaterstaat/waterbase/sea_water_temperature';
   OPT.ylim              = [-5 35]; % -5 for difference plot
   OPT.varname           = 'sea_water_temperature'; % name of data in data and in data and in internal struct
   OPT.hisname           = 'temperature';           % name of data in model output
   OPT.standard_name     = 'sea_water_temperature';
   OPT.tex_name          = 'temperature';
   OPT.code_name         = 'T';
   
end

   % for nc_t_tide_compare
   
   if nargin==0
      varargout = {OPT};
      return
   end
   
   OPT = setproperty(OPT,varargin{:}); % 2/2: overwrite again with user settings
   
%% add full path to be able to save in its subfolders

   if isempty(fileparts(OPT.nc))
      OPT.nc = fullfile(pwd,OPT.nc);
   end

%% load model results
% TO DO: [M,Mmeta]   = nc_cf_timeSeries(OPT.nc,OPT.hisname,'period',OPT.datelim([1 end]))

  [M.datenum,...
   Mmeta.datenum.timezone]   = nc_cf_time(OPT.nc,'time'); % USE nc_cf_time_range()
   M.(OPT.varname)           = nc_varget (OPT.nc,OPT.hisname);
   if nc_isvar(OPT.nc,OPT.hisnamename)
   M.platform_name           = cellstr(nc_varget (OPT.nc,OPT.hisnamename)); % mind getpref ('SNCTOOLS','PRESERVE_FVD')==0
   elseif nc_isvar(OPT.nc,'platform_name')
   M.platform_name           = cellstr(nc_varget (OPT.nc,'platform_name'));
   elseif nc_isvar(OPT.nc,'station_name')
   M.platform_name           = cellstr(nc_varget (OPT.nc,'station_name'));
   end
   M.lon                     = nan;
   M.lat                     = nan;
   Mmeta.(OPT.varname).units = nc_attget(OPT.nc,OPT.hisname,'units'); % in case there is no data
   if isempty(Mmeta.datenum.timezone )
       fprintf(2,['model has no explicit timezone, check whether it is indeed GMT.\n'])
   end
   if ~isempty(OPT.model_timezone)
       Mmeta.datenum.timezone = OPT.model_timezone;
       fprintf(2,['overruled model timezone ',char(Mmeta.datenum.timezone),' with ',OPT.model_timezone,'\n'])
   else
       fprintf(2,['used model timezone from model results attributes: ',char(Mmeta.datenum.timezone),'\n'])
   end

   M.datenum = M.datenum - timezone_code2datenum(char(Mmeta.datenum.timezone)) + timezone_code2datenum(OPT.timezone);

%% prepare

   FIG(1) = figure('name','time series','position',[100   300   560   420]);
   FIG(2) = figure('name','scatter'    ,'position',[668   300   560   420]);
   
   nc_t_tide_datas  = {};
   nc_t_tide_models = {};

%%  Find associated observational data
%   check "mapping of data to model"
%   while "mapping of model to data" is checked in actual loop below (unique mapping)

if ischar(OPT.platform_data_url)

   OPT.ncbase = OPT.platform_data_url;
   OPT.platform_data_url = cell([1 length(OPT.platform_name)]); % initialize same size as # stations
    
   dataurls = opendap_catalog(OPT.ncbase);
   
   %% loop model platform index (im) and find associated data platform index (id)
   for im=1:length(M.platform_name);
   
     if ismember(upper(M.platform_name{im}),upper(OPT.platform_name)) | isempty(OPT.platform_name)
    
   % TODO replace (i) by more intelligent query based on location instead
   % of name, or wait for RDF names with uuids

     [bool,ind] = strfindb(upper(dataurls),upper(strtok(M.platform_name{im})));
     if all(bool==0)
        error(['No matching data found in ',char(OPT.platform_data_url)]);
     end
     id = strmatch(upper(M.platform_name{im}),upper(OPT.platform_name));
     OPT.platform_data_url{id} = dataurls{bool};
     
     end;
   end
   
elseif length(OPT.platform_data_url) ~=length(OPT.platform_name)

   error('not all platforms have an associated data url')

end % ischar

if isempty(OPT.platform_period)
  OPT.platform_period = cell([1 length(OPT.platform_name)]);
else
  if (length(OPT.platform_period)~=length(OPT.platform_name))
     error('''platform_period'' should either be [] or be a cell with same size as ''platform_name''')
  end
end

%% loop data platform index (id) and find associated model platform index (im)
for id=1:length(OPT.platform_name);

   disp(['>> Processing ',OPT.platform_name{id}])
   if ~isempty(OPT.platform_period{id})
   disp(['>> ---------- ',OPT.platform_data_url{id}])
   disp(['>> ---------- ',datestr(OPT.platform_period{id}(1)),' - ',datestr(OPT.platform_period{id}(2))])
   end
   
   if ~strcmp(isempty(OPT.platform_match),'exact')
      im = strmatch(upper(OPT.platform_name{id}),upper(M.platform_name));
   else
      im = strmatch(upper(OPT.platform_name{id}),upper(M.platform_name),OPT.platform_match);
   end
   
   if length(im) > 1
      disp(char({M.platform_name{im}}))
      warning(['Used 1st one from multiple matches found for data platform:',upper(OPT.platform_name{id})])
      im = im(1);
   end
  
%%  Load associated observational data

   if ~isempty(OPT.platform_data_url{id})
   
     if isempty(OPT.platform_period{id})
     [D,Dmeta] = nc_cf_timeseries(OPT.platform_data_url{id},OPT.varname,'period',            OPT.datelim([1 end])); % returns lon,lat too
     else
     [D,Dmeta] = nc_cf_timeseries(OPT.platform_data_url{id},OPT.varname,'period',OPT.platform_period{id}([1 end])); % returns lon,lat too
     end
     
     unitsfac = 1;           
     if ~isequal(Mmeta.(OPT.varname).units, Dmeta.(OPT.varname).units)
     disp(['units of model and data differ, model: "',...
               char(Mmeta.(OPT.varname).units),'"   - data: "',...
               char(Dmeta.(OPT.varname).units),'": ',...
               'converted to model units: ',char(Dmeta.(OPT.varname).units)]);
     unitsfac = convert_units(char(Dmeta.(OPT.varname).units),char(Mmeta.(OPT.varname).units));
     end
     
     if isempty(Dmeta.datenum.timezone )
         fprintf(2,['data has no explicit timezone, check whether it is indeed GMT.\n'])
     end
     
     D.datenum = D.datenum -timezone_code2datenum(char(Dmeta.datenum.timezone)) +timezone_code2datenum(OPT.timezone);
     
     % copy meta-data that is not in model output (yet ...)
     M.lon           = D.lon;
     M.lat           = D.lat;
     M.platform_id   = D.platform_id;
    %M.platform_name = D.platform_name;
   
     OPT.ext = [OPT.code_name,'_',datestr(OPT.datelim(1),OPT.datefmt),'_',datestr(OPT.datelim(end),OPT.datefmt)];
     if length(OPT.ext)==1
        OPT.ext = '';
     end
     
     OPT.txt = mktex({['Created with OpenEarthTools <www.OpenEarth.eu> ',OPT.ext],...
                   ['model: ',filename(OPT.nc),' & data:',OPT.platform_data_url{id}]}); % ,' @ ',datestr(now,'yyyy-mmm-dd')
   
%%  process comparisons (difference and scatter) only if observational data is present
    
     D.title = {OPT.label,[mktex(char(D.platform_name(:)')),' (',...
                           mktex(char(D.platform_id(:)')),') [',...
                           num2str(D.lon),'\circ E, ',...
                           num2str(D.lat),'\circ N]']};

     if ~isempty(D.datenum) & isempty(OPT.platform_period{id})
       
        %% interpolate model to data times in common timezone

        DM.(OPT.varname) = interp1(M.datenum,M.(OPT.varname)(:,im),D.datenum)';  % mind getpref ('SNCTOOLS','PRESERVE_FVD')==0
        if prod(size(DM.(OPT.varname)))==0
            fprintf(2,['data ',datestr(D.datenum(1)),'-',datestr(D.datenum(1)),' and model ',datestr(D.datenum(1)),'-',datestr(D.datenum(1)),' periods do not overlap.\n'])
        end

        DM.(OPT.varname) = reshape(DM.(OPT.varname),size(D.(OPT.varname)));
    
%% plot timeseries difference

        figure(FIG(1));subplot_meshgrid(1,1,.05,.05);clf
        
        plot    (D.datenum,DM.(OPT.varname) - D.(OPT.varname).*unitsfac,'g','LineStyle',OPT.linestyle,'DisplayName','model - data')
        legend  ('Location','NorthEast')
        title   (D.title)
        grid on
        ylim    (OPT.ylim)
        xlabel  ({'',['timezone: ',OPT.timezone]})
        ylabel  ([OPT.tex_name,' [',mktex(Dmeta.(OPT.varname).units),']']);
        timeaxis(OPT.datelim,'fmt',OPT.datestr,'tick',-1,'type','text'); %datetick('x')
        text    (1,0,OPT.txt,'rotation',90,'units','normalized','verticalalignment','top','fontsize',6)
        
        print2screensizeoverwrite([fileparts(OPT.nc),filesep,'timeseries',filesep,OPT.ext,filesep,filename(OPT.nc),'_',OPT.ext,'_',mkvar(M.platform_name{im}),'_diff.png']) % ,'v','t'

%% plot time series scatter
%  TO DO: calculate R2 or GoF or Taylor diagram ??
%  TO DO: show density of points

        figure(FIG(2));subplot_meshgrid(1,1,.05,.05);clf
        mask = (~isnan(DM.(OPT.varname))) & (~isnan(D.(OPT.varname))); % begin/endpooints might be NaN in case of to time zone shift
        maxe =      max(DM.(OPT.varname)(mask) - D.(OPT.varname)(mask));
        mine =      min(DM.(OPT.varname)(mask) - D.(OPT.varname)(mask));
        rmse =      rms(DM.(OPT.varname)(mask) - D.(OPT.varname)(mask));
        R    = corrcoef(DM.(OPT.varname)(mask)  ,D.(OPT.varname)(mask));
        if length(R) > 1 % for really coarse Niskin data
           R = R(2,1); % same as (2,1)
        else
           R = NaN; % same as (2,1)
        end
        
        fmte = '%+1.3f'; %
        txte = {[' R    = ',num2str(R   ,fmte)],...
                [' #    = ',num2str(sum(mask),'%d')],...
                [' \epsilon_{rms}  = ',num2str(rmse,fmte)],...
                [' \epsilon_{min}  = ',num2str(mine,fmte)],...
                [' \epsilon_{max}  = ',num2str(maxe,fmte)]};

        plot    (D.(OPT.varname).*unitsfac,DM.(OPT.varname),'k.','DisplayName','model vs. data') % model on y-axis: 'model to high' visible as higher results
        hold on
        title   (D.title)
        text    (0,1,txte,'units','normalized','verticalalignment','top','FontName','fixedwidth')
        grid on
        axis equal
        ylim  (OPT.ylim)
        ylabel(['\color{blue}',OPT.tex_name,' [',mktex(Dmeta.(OPT.varname).units),'] (model)'])
        xlim  (OPT.ylim)
        xlabel(['\color{red}',OPT.tex_name,' [',mktex(Dmeta.(OPT.varname).units),'] (data)'])
        plot  (xlim,ylim,'k--','linewidth',1)
        for deta = [.25 .5]
        plot  (xlim+deta,ylim-deta,'k:')
        plot  (xlim-deta,ylim+deta,'k:')
        end
        text    (1,0,OPT.txt,'rotation',90,'units','normalized','verticalalignment','top','fontsize',6)
        
        print2screensizeoverwrite([fileparts(OPT.nc),filesep,'timeseries',filesep,OPT.ext,filesep,filename(OPT.nc),'_',OPT.ext,'_',mkvar(M.platform_name{im}),'_scatter.png'],[1024],[120],[-257 0]) % ,'v','t'

     end % if ~isempty(D.datenum)

%% plot time series (only if data is present)

     figure(FIG(1));subplot_meshgrid(1,1,.05,.05);clf
     plot    (M.datenum,M.(OPT.varname)(:,im),'b','DisplayName','model')
     hold on
     if ~isempty(OPT.platform_data_url{id})    
     plot    (D.datenum,D.(OPT.varname).*unitsfac,'r','LineStyle',OPT.linestyle,'DisplayName','data')
     title   (D.title)
     else
     title   ({OPT.label,char(M.platform_name(:,im))});
     end
     legend  ('Location','NorthEast')
     grid on
     ylim    (OPT.ylim)
     xlabel  ({'',['timezone: ',OPT.timezone]})
     ylabel  ([OPT.tex_name,'[',mktex(Dmeta.(OPT.varname).units),']']);
     timeaxis(OPT.datelim,'fmt',OPT.datestr,'tick',-1,'type','text'); %datetick('x')
     text    (1,0,OPT.txt,'rotation',90,'units','normalized','verticalalignment','top','fontsize',6)
     
     print2screensizeoverwrite([fileparts(OPT.nc),filesep,'timeseries',filesep,OPT.ext,filesep,filename(OPT.nc),'_',OPT.ext,'_',mkvar(M.platform_name{im}),'.png']) % ,'v','t'
    
%%  perform tidal analysis

     if OPT.t_tide
     
      nc_t_tide_data  = [fileparts(OPT.nc),filesep,'t_tide_data',filesep,mkvar(M.platform_name{im})                     ,'_t_tide.nc'];
     asc_t_tide_data  = [fileparts(OPT.nc),filesep,'t_tide_data',filesep,mkvar(M.platform_name{im})                     ,'_t_tide.t_tide'];
      nc_t_tide_model = [fileparts(OPT.nc),filesep,'t_tide'     ,filesep,filename(OPT.nc),'_',mkvar(M.platform_name{im}),'_t_tide.nc'];
     asc_t_tide_model = [fileparts(OPT.nc),filesep,'t_tide'     ,filesep,filename(OPT.nc),'_',mkvar(M.platform_name{im}),'_t_tide.t_tide'];
     
     if isempty(D.datenum)
         TTD = [];
     else
        if isempty(OPT.platform_period{id})
          tlim = OPT.datelim([1 end]);
        else
          tlim = OPT.platform_period{id}([1 end]);
        end     

        if isempty(D.lat)
           lat = 45; % ensur enodal correction, 0 yields some nans
        else
           lat = D.lat;
        end
        
        TTD = t_tide2struc(D.datenum,D.(OPT.varname).*unitsfac,... % add period and midpoint
                 'lat',lat,...
              'period',tlim,... % OPT.datelim, ... % D.datenum([1 end]),...
             'ascfile',asc_t_tide_data,...
                'sort','-amp');
            
      TTD.position.latitude  = D.lat;
      TTD.position.longitude = D.lon;
      TTD.name = D.platform_name;
        
        t_tide2nc(TTD,'filename',nc_t_tide_data,...
          'platform_id',D.platform_id',...
        'platform_name',D.platform_name',...
                'units',Dmeta.(OPT.varname).units)
        clear D
     end %   if ~isempty(D.datenum)

     if isempty(M.lat)
        lat = 45; % ensure nodal correction, 0 yields some nans, so we guess 45
     else
        lat = M.lat;
     end     

        TTM = t_tide2struc(M.datenum,M.(OPT.varname)(:,im),...% add period and midpoint
                 'lat',lat,...
              'period',OPT.datelim,... % OPT.datelim, ... % D.datenum([1 end]),...
             'ascfile',asc_t_tide_model,...
                'sort','-amp');
            
      TTM.position.latitude  = M.lat;
      TTM.position.longitude = M.lon;
      TTM.name = M.platform_name;
        
        t_tide2nc(TTM,'filename',nc_t_tide_model,...
          'platform_id',M.platform_id,...
        'platform_name',M.platform_name{im},...
                'units',Dmeta.(OPT.varname).units);
      
     if OPT.pause;pausedisp;end

     % if t_tide succesful, remembers platforms 
     % for which model and data are present for tidal comparison
     if  ~isempty(TTD)
        nc_t_tide_datas {end+1} = nc_t_tide_data ;
        nc_t_tide_models{end+1} = nc_t_tide_model;
     end
    
   end % OPT.t_tide
    
   end % if ~isempty(OPT.platform_data_url{id})
    
end % platform loop

%%  plot tidal analysis

   if OPT.t_tide
   %-% make sure these match pairwise
   %-% nc_t_tide_model              = sort(opendap_catalog(fileparts(OPT.nc),filesep,'t_tide'));
   %-% nc_t_tide_data               = sort(opendap_catalog(fileparts(OPT.nc),filesep,'t_tide_data');

   myfile = [fileparts(OPT.nc),filesep,'t_tide',filesep];
   
   if ~isempty(OPT.platform_data_url)
   nc_t_tide_compare(nc_t_tide_models,...
                     nc_t_tide_datas ,'export',1,...
                                        'vc',OPT.vc,...
                                      'axis',OPT.axis,...
                                 'directory',myfile,...
                         'verticalalignment','top',...
                       'horizontalalignment','left',...
                                      'plot',OPT.plot);
   end
   end
