function varargout = opendap_get_cache(varargin)
%OPENDAP_GET_CACHE  download all netcdf files from one opendap server directory
%
%    opendap_get_cache(<keyword,value>)
%
% Example:
%
% opendap_get_cache('server_root','http://opendap.deltares.nl/thredds/',...
%                    'local_root','e:\opendap\',...
%                  'dataset','/rijkswaterstaat/grainsize/',... % will be appended to both 'server' and 'local' directory
%                    'pause',1); % first time try with pause on
%
% pause = 2 pasues after every file, pause = 1 pauses only after verifying local directory
%
% Creates a cache of all netCDF files in:
%   http://opendap.deltares.nl/thredds/fileServer/opendap/rijkswaterstaat/grainsize/
% into :
%   E:\opendap\rijkswaterstaat\grainsize\
%
%See also: OPENDAP_CATALOG, SNCTOOLS
%          https://publicwiki.deltares.nl/display/OET/OPeNDAP+caching+on+a+local+machine

%% specify

   OPT.server_root = 'http://opendap.deltares.nl/thredds/';
   OPT.local_root  = 'D:/opendap.deltares.nl/thredds/';
   OPT.dataset     = '';
  %OPT.dap2ftpFcn  = @(x) strrep(x,'dodsC','fileServer')
   OPT.pause       = 1; % default verify only directory, set to 2 to verify every file
   
   if nargin==0
      varargout = {OPT};
      return
   end
   
   OPT = setproperty(OPT,varargin);
   
   base_url = path2os([OPT.server_root,'/fileServer/opendap/',OPT.dataset],'h');
   base_loc = path2os([OPT.local_root,                        OPT.dataset]);
   
   mkdir(base_loc)

%% find ncfiles

   list = opendap_catalog(path2os([OPT.server_root,'/catalog/opendap/',OPT.dataset,'/catalog.xml']));
   
   if ~isempty(list)
      list = cellstr(filenameext(char(list)));

%% download all one by one

      disp(['Downloading to: '])
      disp([base_loc])
      if OPT.pause
      pausedisp
      end

      nnc = length(list);
      tic
      for inc=1:nnc
          
         ncfile = list{inc};
         fprintf(['%0.4d of %0.4d : %s '],inc,nnc,ncfile);
         if OPT.pause>1
         pausedisp
         end
          
         urlwrite(path2os([base_url,filesep,ncfile],'h'),...
                          [base_loc,filesep,ncfile]);
              
         tmp=toc;
         fprintf([' (passed time is %f s) \n'],tmp);
              
      end
   end