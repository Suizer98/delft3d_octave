function [OPT, Set, Default] =knmi_noaapc2kml(noaapcfile,varargin)
%KNMI_NOAAPC2KML   PRELIMINRARY FUNCTION to save NOAAPC file as tiled kml png (BETA!!!)
%
%   knmi_noaapc2kml(noaapcfile,<keyword,value>)
%
% Note: for surf you must change reversePoly if the grid cells are too 
%       dark during the day, and light during the night.
%
% Example:
%
%    knmi_noaapc2kml('K010590N.SST','clim',[6 14]);
%
%See also: KMLfig2png, knmi_noaapc_read

% TO DO : read netCDF data instead of binary noaapc files
% TO DO : remove hard directory and noaapcfiles-list

tic

   OPT.directoryin  = 'F:\checkouts\OpenEarthRawData\knmi\noaapc\mom\1990_mom\5\';
   OPT.directoryout = '.kml';
   OPT.opendap      = 'http://opendap.deltares.nl:8080/';
   OPT.clim         = [10 14]; % same as icons in http://dx.doi.org/10.1016/j.csr.2007.06.011
   OPT.disp         = 1; % toc per image
   noaapcfiles      = {'K010590N.SST',...% 1 % Do make sure they are in chronological order, 4 images/day
                       'K020590N.SST',...% 2 % N =  ~2AM night
                       'K020590M.SST',...% 3 % O =  ~6AM morning
                       'K020590A.SST',...% 4 % M = ~12AM (after)noon
                       'K030590N.SST',...% 5 % A =  ~6PM evening
                       'K030590O.SST',...% 6
                       'K030590M.SST',...% 7
                       'K030590A.SST',...% 8
                       'K040590N.SST',...% 9
                       'K040590O.SST',...%10
                       'K040590M.SST',...%11
                       'K040590A.SST',...%12
                       'K050590N.SST',...%13
                       'K050590O.SST',...%14
                       'K050590M.SST',...%15
                       'K060590N.SST',...%16
                       'K060590O.SST',...%17
                       'K060590M.SST',...%18
                       'K070590N.SST',...%19
                       'K080590M.SST',...%20
                       'K080590A.SST'};  %21
%   [OPT, Set, Default] =setproperty(OPT,varargin{:});
%   
%   if nargin==0
%      return
%   end

   %% read 1st image
   noaapcfile = noaapcfiles{1};
   D = knmi_noaapc_read([OPT.directoryin,filesep,noaapcfile],'landmask',nan);
   
   nfile = length(noaapcfiles);

for ifile= 1:nfile

   disp(['Processing ',num2str(ifile),'/',num2str(nfile),' @ ',datestr(D.datenum)])
   
   if ifile==nfile
   NEXT.datenum = D.datenum + 1/24;
   else
   noaapcfile   = noaapcfiles{ifile+1};
   NEXT         = knmi_noaapc_read([OPT.directoryin,filesep,noaapcfile],'landmask',nan);
   end
   
   if NEXT.datenum < D.datenum
      error(['images not in chronological order: #',num2str(ifile +1),' is before #',num2str(ifile)]);
   end
   
   fname       = ['N',datestr(D.datenum,30),'_SST.nc'];
   
   urls = ...
   ['(<a href="',OPT.opendap,     'thredds/dodsC/opendap/knmi/NOAA/mom/1990_mom/5/',fname,'.html">','THREDDS</a>,',...
     '<a href="',OPT.opendap,                   'opendap/knmi/NOAA/mom/1990_mom/5/',fname,'.html">','HYRAX</a>,',...
     '<a href="',OPT.opendap,'thredds/fileServer/opendap/knmi/NOAA/mom/1990_mom/5/',fname,     '">','ftp</a>)'] ;
   
   h = pcolorcorcen(D.loncor,D.latcor,D.data);
   caxis(OPT.clim)
   colorbarwithtitle([D.producttex,' [',D.unitstex,']']);
   KMLfig2png(h,'fileName',[filename(D.filename),'.kml'],...
                 'kmlName',[D.product,' [',D.units,'] ',datestr(D.datenum,'yyyy-mmm-dd HH-MM-SS')],...
             'description',[D.product,' [',D.units,'] product from <a href="http://www.knmi.nl/onderzk/applied/sd/en/AVHRR_archive_KNMI.html"> KNMI</a> ',...
                           'from data recored by the <a href="http://www.oso.noaa.gov/poes/"> NOAA POES AVHRR instrument</a>: ',...
                           '',D.satellite,num2str(D.satnum),' on ',datestr(D.datenum,'yyyy-mmm-dd HH-MM-SS'),...
                           ' provided as kml and via ',urls,' by <a href="http://www.OpenEarth.eu"> OpenEarthTools</a>'],...
                  'levels',[-1 3],... % sufficient for 1 km resolution
                  'timeIn',D.datenum,...
             'scaleHeight',false,...
                 'timeOut',NEXT.datenum); % stop with next image
                  
   D    = NEXT;

   if OPT.disp
   num2str(['file #:',num2str(ifile),', time elapsed: ',num2str(toc)])
   end

   if OPT.pause
      pausedisp
   end

end

   
%% vectgorized image is bad idea:

%  TOOOOOOOOOOOOOOO BIG (180 MB for one whole North Sea image)
   
   %KMLpcolor(D.loncor,D.latcor,D.data,...
   %          'fileName',[filename(noaapcfile),'.kml'],...
   %       'reversePoly',OPT.reversePoly,...
   %              'clim',OPT.clim,...
   %           'kmlName',[D.product,' [',D.units,']']);

%%EOF

