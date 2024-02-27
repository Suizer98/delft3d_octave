function netcdf_settings(varargin)
%NETCDF_SETTINGS   set netCDF snctools plus java OPeNDAP support, fix legacies/bugs
%
% Tested for the following releases (using NETCDF_TEST):
%
% * 2006b FAIL mexnc_legacy added, default java for read-only (no write possible)
% * 2007a FAIL mexnc_legacy added, default java for read-only (no write possible)
% * 2007b FAIL mexnc_legacy added, default java for read-only (no write possible)
% * 2008a FAIL mexnc_legacy added, default java for read-only (no write possible)
% * 2008b OK, add yourselves http://www.mathworks.com/support/bugreports/609383
% * 2009a OK, add yourselves http://www.mathworks.com/support/bugreports/609383
% * 2009b OK, add yourselves http://www.mathworks.com/support/bugreports/609383
% * 2010a OK
% * 2010b OK
% * 2011a OK
% * 2011b OK
% * 2012a OK
%
% For reading large netCDF files with Java memory issues can arise, see:
% http://www.mathworks.com/support/solutions/en/data/1-18I2C/
% see also: java.lang.Runtime.getRuntime.gc
%
%See also: OETSETTINGS, NC_CF_GRID_TEST, NETCDF_TEST, JAVARMPATH

%% Retrieve verbose state from input

   OPT.quiet = false;
   nextarg   = 1;
   
   if mod(nargin,2)==1 % odd # arguments
       if strcmp(varargin{1},'quiet')
       OPT.quiet = true;
       else
          error(['unknown argument:',varargin{1}])
       end
       nextarg   = 2;
   end
   
   OPT = setproperty(OPT,varargin{nextarg:end});

%% remove any netcdf paths already added by oetsettings

   S      = [fileparts(which('oetsettings'))  filesep];
   ncroot = [fileparts(mfilename('fullpath')) filesep];
      
   if ~isempty(S)
     
     % prevent error message of .svn directories
     % that were not added by addpathfast
     state = warning;
     warning off
     rmpath    ((genpath([S,filesep,'io',filesep,'netcdf'])));
     warning(state)
     
     %rmpath    ((genpath([S,filesep,'io',filesep,'netcdf',filesep,'2008a'])));
     %rmpath    ((genpath([S,filesep,'io',filesep,'netcdf',filesep,'2009'])));
     %rmpath    ((genpath([S,filesep,'io',filesep,'netcdf',filesep,'mexnc'])));
     %rmpath    ((genpath([S,filesep,'io',filesep,'netcdf',filesep,'mexnc_legacy'])));
     %rmpath    ((genpath([S,filesep,'io',filesep,'netcdf',filesep,'snctools'])));

     %javarmpath(([S,'io',filesep,'nctools',filesep,'toolsUI-2.2.22.jar'])); % needs exact // \\
     %javarmpath(([S,'io',filesep,'nctools',filesep,'toolsUI-4.0.jar']));    % needs exact // \\
     
   else
   
      disp('  netCDF: Run OETSETTINGS before NETCDF_SETTINGS !')
      
   end

%% Add nctools and snctools

%  these paths are updated occasionally to the appropriate mexcdf version
%  available at: http://mexcdf.sourceforge.net/
%                http://sourceforge.net/projects/mexcdf/
%  Note that OET may contain some (temporary) modifications with respect to 
%  the official mexcdf (email changes to the mexcdf moderator John Evans.)

      addpath( ncroot                            ); % do not add 'switch' dirs
      addpathfast([ncroot,filesep,'snctools'    ]);
      addpathfast([ncroot,filesep,'nctools'     ]);
      addpathfast([ncroot,filesep,'mexnc'       ]); % snctools needs some mexnc stuff
      addpathfast([ncroot,filesep,'kickstarter' ]);
      
%% Use recent java API for OPeNDAP functionality
%  (NB RESTOREDEFAULTPATH does not restore such a java path)
%  http://mexcdf.sourceforge.net/tutorial/ch02.html
%  "It's possible to use an opendap-enabled version of mexnc 
%   for your opendap connectivity (rather than java), 
%   but I don't really recommend it. "

   vs = datenum(version('-date'));
   if (vs > datenum(2003,1,1)) 

      if     any(strcmpi(version('-release'),{'14','2006a','2006b','2007a','2007b','2008a'}))
           fprintf(2,'  netCDF: Writing netcdf files does not work due to vanilla_mexnc issues, you need 2008b and higher to write netcdf files or solve vanilla_mexnc.\n')
      end
      
      if     any(strcmpi(version('-release'),{'2006a','2006b','2007a'}))
      java2add         = path2os([ncroot,filesep,'netcdfAll-4.1.jar']); % 'toolsUI-4.1.jar' has same functionality but is bigger. It returns an old CF number for GRIB files.
      elseif strcmpi(version('-release'),'14')
      java2add         = path2os([ncroot,filesep,'netcdf-2.2.20.jar']); %
      else % 'R2007b' and higher
      java2add         = path2os([ncroot,filesep,'netcdfAll-4.2.jar']); % 'toolsUI-4.2.jar' has same functionality but is bigger
      end

      dynjavaclasspath = path2os(javaclasspath);
      indices          = strfind(javaclasspath,java2add);
       
       if isempty(cell2mat(indices))
           javaaddpath (java2add)
         if ~(OPT.quiet)
           disp( '  netCDF: Adding <a href="http://www.unidata.ucar.edu/software/netcdf-java/">netCDF-JAVA</a>, please wait ...')
           disp(['  netCDF: netCDF-JAVA library for OPeNDAP support added: ',filename(java2add)]);
           disp(['  netCDF: Note: maximal size of java memory is = ',num2str(java.lang.Runtime.getRuntime.maxMemory/2^20),' Mb']); % 2^20 = 1 Mbyte, default 130875392=124Mb
           disp( '          Loading large matrices gives java heap errors, for expansion see:')
           disp( '          http://www.mathworks.com/support/solutions/en/data/1-18I2C/')
         end
   
       elseif ~(OPT.quiet)
           disp(['  netCDF: Java path not added, already there: ',java2add]);
       end
       
       try % matlab fails if several instances of matlab are accessing matlabprefs.mat, tgis hapens whne one users has many matlab instances running
       setpref ( 'SNCTOOLS','USE_JAVA'       , 1); % Allow java, This requires SNCTOOLS 2.4.8 or better
      %setpref ( 'SNCTOOLS','USE_NETCDF_JAVA', 1); % Force java: do in case of troubles with native netcdf.x toolbox (url via proxy is an issue)
       if ~(OPT.quiet)
           disp('  netCDF: setpref( ''SNCTOOLS'',''USE_JAVA''   , 1) % use of java for remote urls to avoid OPeNDAP bug in native package');
       end
       % keep snctools default
       setpref ( 'SNCTOOLS','PRESERVE_FVD',0); % 0: backwards compatibility and consistent with ncBrowse
                                               % 1: We do not want to transpose matrices because:
                                               %    (i)  we have some LARGE datasets and need a performance boost
                                               %    (ii) some use the netCDF API directly which does not do this. 
                                               %    May break previous work though ...
       if ~(OPT.quiet)
           disp('  netCDF: setpref( ''SNCTOOLS'',''PRESERVE_FVD'',0) % ncread and nc_varget have different matrix orientation');
       end
       catch
           fprintf(2,'  netCDF: failed to set SNCTOOLS prefs due to matlab concurrence issue\n')
       end
                                              
       %% add basic authentication class
       
       javaaddpath(fullfile(fileparts(mfilename('fullpath')), 'snctools', 'classes'))
   
   else
       
       if ~(OPT.quiet)
           disp('  netCDF: Java path not added, your version of matlab is too old: no OPeNDAP support.');
       end
       
   end

%% Fix legacies

   if     strcmpi(version('-release'),'14')    | ... % Undefined command/function 'vanilla_mexnc'.
          strcmpi(version('-release'),'2006a')
          
          fprintf(2,'snctools not fully supported for R14(SP3) or 2006a: WRITING NEVER POSSIBLE, READING IN SOME CASES.')
          
   elseif strcmpi(version('-release'),'2006b') | ... % OK, despite "Exception in thread "Thread-12" java.lang.ArrayIndexOutOfBoundsException: -1"
          strcmpi(version('-release'),'2007a') | ... % OK
          strcmpi(version('-release'),'2007b') | ... % OK
          strcmpi(version('-release'),'2008a')       % OK

      addpathfast([ncroot,filesep,'mexnc_legacy']);
      
%% Fix bugs

      %  http://www.mathworks.com/support/bugreports/609383
      %  609383
      %  Summary
      %  
      %  MATLAB NetCDF package does not allow empty attributes
      %  Description
      %  
      %  MATLAB's NetCDF package (netcdf) disallows writing empty attributes, 
      %  but this is a feature that is in fact allowed by the library.
      %
      %  Workaround
      %  
      %  To work around this issue, replace the following files in your existing 
      %  MATLAB installation with the updated versions, attached.
      %  
      %     1. Type matlabroot at the MATLAB prompt.
      %     2. Quit MATLAB.
      %     3. Change folders into $matlabroot/toolbox/matlab/imagesci.
      %     4. Change the name of the folder +netcdf to netcdf-old
      %     5. Unzip the appropriate attachment into the current folder. If you 
      %        are using R2008b, then use R2008b.zip. If you are using R2009a or 
      %         R2009b, then use R2009ab.zip
      %     6. Restart MATLAB.
      %     7. Type rehash toolboxcache at the MATLAB prompt.
      %  
      %  Fix
      %  
      %  This bug was fixed as of R2010a(7.10).
      %  
      %  If you have a current subscription to MathWorks Software Maintenance Service (SMS), 
      %  you can download product updates. If not, learn more about MathWorks SMS. 
      
% however, this fix results in an the following error on some machines

%  ??? Invalid MEX-file 'D:\checkouts\openearthtools\matlab\io\netcdf\2008b\+netcdf\private\netcdflib.mexw64': This
%  application has failed to start because the application configuration is incorrect. Reinstalling the application may
%  fix this problem.
%  
%  Error in ==> inqLibVers at 20
%  libvers = netcdflib('inqLibVers');
%  
%  Error in ==> mexnc_tmw>handle_inq_libvers at 149
%  output = netcdf.inqLibvers();
%  
%  Error in ==> mexnc_tmw at 111
%      [varargout{:}] = handler ( varargin{:} );
%  
%  Error in ==> mexnc at 539
%  	[varargout{:}] = backend(varargin{:});
%  
%  Error in ==> snc_read_backend at 34
%  v = mexnc('inq_libvers');
%  
%  Error in ==> nc_info at 49
%  [backend,fmt] = snc_read_backend(ncfile);
%  
%  Error in ==> nc_cf_grid at 107
%        fileinfo = nc_info(ncfile);
%  
%  Error in ==> nc_cf_grid_test at 13
%     [G,GM] =nc_cf_grid(f,'z');

   elseif strcmpi(version('-release'),'2008b')       % OK
   
     %addpathfast([ncroot,filesep,'2008b'],'append',0); % overrule erronous +netcdf in matlab path by prepadding

      if ~(OPT.quiet)
      disp('  netCDF: note: netcdf and snctools use different matrix orientation: see nc_dump');
      end
   
   elseif strcmpi(version('-release'),'2009a') | ... % OK
          strcmpi(version('-release'),'2009b') 
          
     %addpathfast([ncroot,filesep,'2009' ],'append',0); % overrule erronous +netcdf in matlab path by prepadding

      if ~(OPT.quiet)
      disp('  netCDF: note: netcdf and snctools use different matrix orientation: see nc_dump');
      end

%% Fix legacies/bugs not needed

   elseif (vs > datenum(2010,1,1)) 

      if ~(OPT.quiet)
      disp('  netCDF: note: netcdf and snctools use different matrix orientation: see nc_dump');
      end

   else
   
      warning('  netCDF: snctools not supported for releases before R14 or 2006a')
   
   end
   
   if ~OPT.quiet
      disp('  netCDF: settings enabled! ');
   end

%% EOF   
