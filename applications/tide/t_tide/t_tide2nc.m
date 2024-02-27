function t_tide2nc(D,varargin)
%t_tide2nc store t_tide constituents as nc
%
% str = t_tide2nc(D) where D = t_tide2struc() or t_tide_read()
%
% Example: t_tide2nc(D,'filename','test.nc');
%
%See also: t_tide, t_tide2struc, t_tide_read, t_tide2html, t_tide2xml

warning('deprecated in favor of tide_iho.m method to_nc')

% IHO xml keywords	 
   
D0.name                = '';
D0.country             = '';
D0.position.latitude   = '';
D0.position.longitude  = '';
D0.timeZone            = [];
D0.units               = '';
D0.observationStart    = '';
D0.observationEnd      = '';
D0.comments            = '';
   
OPT.filename           = '';
OPT.refdatenum         = datenum(1970,1,1);
OPT.units              = '?';
OPT.title              = ' ';
OPT.institution        = ' ';
OPT.source             = ' ';
OPT.history            = ' ';
OPT.email              = ' ';
OPT.platform_id        = '';
OPT.platform_name      = '';

if nargin==0
    varargout = {OPT};
    return
end
OPT = setproperty(OPT,varargin);

if ~isempty(OPT.filename)
      
  % TO DO: start using native matlab ncwritschema

   nc_create_empty(OPT.filename);
   
   %nc_attput(OPT.filename, nc_global, 'title'         , OPT.title);
   %nc_attput(OPT.filename, nc_global, 'institution'   , OPT.institution);
   %nc_attput(OPT.filename, nc_global, 'source'        , OPT.source);
   %nc_attput(OPT.filename, nc_global, 'history'       , OPT.history);
   nc_attput(OPT.filename, nc_global, 'references'    , 'Pawlowicz, R., B. Beardsley, and S. Lentz, "Classical Tidal Harmonic Analysis Including Error Estimates in MATLAB using T_TIDE", Computers and Geosciences, 2002. http://dx.doi.org/10.1016/S0098-3004(02)00013-4');
   %nc_attput(OPT.filename, nc_global, 'email'         , OPT.email);
   
   nc_attput(OPT.filename, nc_global, 'version'       , '$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/tide/nc_t_tide.m $ $Id: nc_t_tide.m 10236 2014-02-17 17:24:09Z boer_g $');
   nc_attput(OPT.filename, nc_global, 'Conventions'   , 'CF-1.4');
   nc_attput(OPT.filename, nc_global, 'disclaimer'    , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
   
   % TO DO: add other meta-info from t_tide such as history and stuff from t_tide ASCII file
   
   nc_adddim      (OPT.filename,'frequency',length(D.data.frequency));
   nc_adddim      (OPT.filename,'strlen0'  ,1);
   nc_adddim      (OPT.filename,'strlen1'  ,size(char(D.data.name),2)); % component names
   
   if isempty(OPT.platform_id  );OPT.platform_id   = D.name;
   end
   if isempty(OPT.platform_name);OPT.platform_name = D.name;
   end
   
   nc_adddim      (OPT.filename,'strlen2'  ,length(OPT.platform_id));
   if length(OPT.platform_name) > 0
   nc_adddim      (OPT.filename,'strlen3'  ,length(OPT.platform_name));
   end
   nc_adddim      (OPT.filename,'time'     ,1);
   nc_adddim      (OPT.filename,'bounds'   ,2);
  
  if ~isempty(D.name)   
   nc.Name = 'platform_id';
   nc.Datatype     = 'char';
   nc.Dimension    = {'strlen0','strlen2'}; % 2D, otherwise matlab does not load it correctly
   nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'code of station');
   nc.Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'platform_id');
   nc_addvar         (OPT.filename,nc);
   nc_varput         (OPT.filename,nc.Name,OPT.platform_id(:)');clear nc
  end
  if ~isempty(D.name)   
   nc.Name = 'platform_name';
   nc.Datatype     = 'char';
   nc.Dimension    = {'strlen0','strlen3'}; % 2D, otherwise matlab does not load it correctly
   nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'name of station');
   nc.Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'platform_name');
   nc_addvar         (OPT.filename,nc);
   nc_varput         (OPT.filename,nc.Name,OPT.platform_name(:)');clear nc
  end
  if ~(isempty(D.position.longitude) | isempty(D.position.latitude))
   nc.Name = 'longitude';
   nc.Datatype     = 'double';
   nc.Dimension    = {};
   nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'longitude');
   nc.Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'longitude');
   nc.Attribute(3) = struct('Name', 'units'          ,'Value', 'degrees_east');
   nc_addvar         (OPT.filename,nc);
   nc_varput         (OPT.filename,nc.Name,D.position.longitude);clear nc

   nc.Name = 'latitude';
   nc.Datatype     = 'double';
   nc.Dimension    = {};
   nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'latitude');
   nc.Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'latitude');
   nc.Attribute(3) = struct('Name', 'units'          ,'Value', 'degrees_north');
   nc_addvar         (OPT.filename,nc);
   nc_varput         (OPT.filename,nc.Name,D.position.latitude);clear nc
  end
   % TO DO: connect time to amp/phase

   nc.Name = 'time';
   nc.Datatype     = 'double';
   nc.Dimension    = {'time'};
   nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'begin of interval of tidal analysis');
   nc.Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'time');
   nc.Attribute(3) = struct('Name', 'units'          ,'Value',['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd HH:MM')]);
   nc.Attribute(4) = struct('Name', 'bounds'         ,'Value', 'period');
   nc_addvar         (OPT.filename,nc);
   nc_varput         (OPT.filename,nc.Name,datenum(D.observationStart) - OPT.refdatenum);clear nc

   nc.Name = 'period';
   nc.Datatype     = 'double';
   nc.Dimension    = {'time','bounds'};
   nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'begin and end of interval of tidal analysis');
   nc.Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'time');
   nc.Attribute(3) = struct('Name', 'units'          ,'Value',['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd HH:MM')]);
   nc_addvar         (OPT.filename,nc); % 
   if getpref('SNCTOOLS','PRESERVE_FVD')
   nc_varput         (OPT.filename,nc.Name,[datenum(D.observationStart), datenum(D.observationEnd)] - OPT.refdatenum);clear nc % 2D array so shape is relevant
   else
   nc_varput         (OPT.filename,nc.Name,[datenum(D.observationStart), datenum(D.observationEnd)] - OPT.refdatenum);clear nc % 2D array so shape is relevant
   end

   nc.Name = 'component_name';
   nc.Datatype     = 'char';
   nc.Dimension    = {'frequency','strlen1'};
   nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'name of tidal constituent');
   nc_addvar         (OPT.filename,nc);
   nc_varput         (OPT.filename,nc.Name,D.data.name);clear nc
   
   nc.Name = 'frequency';
   nc.Datatype     = 'double';
   nc.Dimension    = {'frequency'};
   nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', D.long_name.frequency);
   nc.Attribute(2) = struct('Name', 'units'          ,'Value', D.cf_units.frequency);
   nc_addvar         (OPT.filename,nc);
   nc_varput         (OPT.filename,nc.Name,D.data.frequency);clear nc
   
   fldnames = {'fmaj','emaj','pha','epha','fmin','emin','finc','einc'};
   for ifld=1:length(fldnames)
      fldname = fldnames{ifld};
      if isfield(D.data,fldname)
      nc.Name = fldname; % D.name.(fldname);
      nc.Datatype     = 'double';
      nc.Dimension    = {'frequency'};
      nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', D.long_name.(fldname));
      nc.Attribute(2) = struct('Name', 'units'          ,'Value',  D.cf_units.(fldname));
      nc.Attribute(3) = struct('Name', 'cell_methods'   ,'Value', 'time: period area: point');
      nc_addvar         (OPT.filename,nc);
      nc_varput         (OPT.filename,nc.Name,D.data.(fldname));clear nc
      end
   end
   
   if isfield(D,'significance')
   nc.Name = 'significance';
   nc.Datatype     = 'int';
   nc.Dimension    = {'frequency'};
   nc.Attribute(1) = struct('Name', 'long_name'      ,'Value',['whether component is significant (1) or not (0)']);
   nc.Attribute(2) = struct('Name', 'flag_values'    ,'Value',[0 1]);
   nc.Attribute(3) = struct('Name', 'flag_meanings'  ,'Value',['"insignificant" "significant(1, snr > ',num2str(OPT.synth),')"']);
   nc_addvar         (OPT.filename,nc);
   nc_varput         (OPT.filename,nc.Name,int8(D.significance));clear nc
   % TO DO flag_values
   % TO DO flag_meanings
   end
   
   nc.Name = 'snr';
   nc.Datatype     = 'double';
   nc.Dimension    = {'frequency'};
   nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'signal to noise ration');
   nc.Attribute(1) = struct('Name', 'comment'        ,'Value', '(amplitude/amplitude_error)^2');
   nc_addvar         (OPT.filename,nc);
   nc_varput         (OPT.filename,nc.Name,D.data.snr);clear nc
   
   nc_dump(OPT.filename,'',[filepathstrname(OPT.filename),'.cdl'])
   
   end % file exist
