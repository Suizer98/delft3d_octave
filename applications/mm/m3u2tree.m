function m3u2tree(fname,destination,varargin)
%M3U2TREE   copies all (mp3) files from a m3u playlist to one directory 
%
%   m3u2tree(m3ufile,destination)
%
% Example: 
%
%   m3u2tree('D:\MP3\freshmix2.m3u','F:\freshmix2');
%
%See also: m3u_read

% TO DO: handle combination of absolute and relative links in m3u file

cp.to   = destination;

%% keywords
OPT.prefix = 1; % [] % prefix like 001 to ensure proper order from playlist
OPT.pause  = 0;

OPT = setproperty(OPT,varargin{:});

%% path
   if ~isdir(cp.to)
      mkpath(cp.to);
   end   

%% loop

   % read relative paths to be able to destination(=cp.to) as new root 
   DAT = m3u_read(fname,'absolute',0);

   cp.from = [filepathstr(DAT.filename),filesep];
   
   % TO DO: find full path of m3u file

   for ifile=1:length(DAT.list)
   
      disp([num2str(ifile,'%0.3d'),' ',DAT.list(ifile).name])
   
      if length(dir(DAT.list(ifile).name))==0
        disp(['Song does not exist: ',[cp.from,filesep,DAT.list(ifile).name]])
      end
      
      if ~isempty(OPT.prefix)
         OPT.prefix = ifile;
      end
      
     %mkpath  (filepathstr([cp.to  ,filesep,DAT.list(ifile).name]))
      copyfile            ([cp.from,filesep,DAT.list(ifile).name],...
                           [cp.to  ,filesep,...% filepathstr(DAT.list(ifile).name),filesep,...
                                            num2str(OPT.prefix,'%0.3d -  '),... % prefix like 001 to ensure proper order from playlist
                                            filenameext(DAT.list(ifile).name)]);
                                            
                                            
      if OPT.pause
      pausedisp
      end
   
   end

%%% EOF