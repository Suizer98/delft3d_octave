function [S,M]=ctd_struct(D,M0,ncolumn,varargin)
%ctd_struct convert matrix output from read to struct
%
%   [S,M]=ctd_struct(D,M)
%
% converts matrix D from donar.read to struct, and updates
% metadata struct M to include dimensions as for a CF trajectory.
%
%  File              = donar.open(diafile)
% [data ,  metadata] = donar.read(File,1,6) % 1st variable, residing in 6th column
% [struct, metadata] = donar.struct(data, metadata)
%
% S.station_id is a unique id that contains all unique positions.
% Use ctd_extract and ctd_plot to merge and plot profiles for one
% such location.
%
% S.profile_id is a unique id per profile, and should probably be replaced
% with unique dia blocks.
%
%         S = 
% 
%                         lon: [153590x1 double]
%                         lat: [153590x1 double]
%                           z: [153590x1 double]
%                     datenum: [153590x1 double]
%                        data: [153590x1 double]
%                       block: [153590x1 double]
%                  station_id: [153590x1 double]
%                  profile_id: [153590x1 double]

%                 station_lon: [36x1 double]
%                 station_lat: [36x1 double]
%                   station_n: [36x1 double]
%
%             profile_datenum: [813x1 double]
%                   profile_n: [813x1 double]   
%
%See also: open, read, disp, trajectory_struct, ctd_timeSeriesProfile

OPT.plot = 0;

if nargin==2
    ncolumn = size(D,2)-2; % last ones are:  /-flags, dia index
end

 % TO DO make (x,y) instead of (lat,lon) when M.data.hdr tells so
 
   M.data = M0;
   
   M.lon.standard_name  = 'degrees_east';
   M.lon.units          = 'Longitude';
   M.lon.long_name      = 'Longitude';

   M.lat.standard_name  = 'degrees_north';
   M.lat.units          = 'Latitude';
   M.lat.long_name      = 'Latitude';

   M.z.standard_name    = 'cm';
   M.z.units            = 'cm';
   M.z.long_name        = 'Vertical coordinate';
   M.z.positive         = 'down';
   
   M.datenum.standard_name = 'time';
   M.datenum.units         = 'days since 1970-01-01';
   M.datenum.long_name     = 'time';
    
   S.lon     = D(:,1);
   S.lat     = D(:,2);
   S.z       = D(:,3);
   S.datenum = D(:,4);
   S.data    = D(:,ncolumn);
  %S.flag    = D(:,ncolumn+1); % always 0: no information
   S.block   = D(:,ncolumn+2);

   S.station_id = []; % define here to ensture proper order in utruct
   S.profile_id = [];
    
%% Store header as global attributes
   
   flds = donar.headercode2attribute(fields(M0.hdr));
   
   for i = 1:1:size(flds,1)
       for j = 1:1:size(    flds{i,2},1)
           attcode =        flds{i,2}{j,1}; % 1 or 2
           %varname =        flds{i,2}{j,2}; -1 for nc_global
           attname =        flds{i,2}{j,3};
           attval  = M0.hdr.(flds{i,1}){attcode};
           %nc_attput(ncfile, varname, attname, attval);
           M.nc_global.(attname) = attval;
         % M.data.nc_global.(attname) = attval;
       end
   end
   
%% Find unique stations

  disp([mfilename,' busy with unique stations'])
  
 [S.station_lon,S.station_lat,S.station_id]=poly_unique(S.lon,S.lat,'eps',0.02);
  S.station_n = 0.*S.station_lon;
  for i=1:length(S.station_lon)
      S.station_n(i) = sum(S.station_id==i);
  end
  
%% Find unique profiles

  disp([mfilename,' busy with unique profiles'])

 [S.profile_datenum,~,S.profile_id]=unique_rows_tolerance(S.datenum,10/24/60); % correlates very well with dia blocks, use unique() on that?
  S.profile_n = 0.*S.station_lon;
  for i=1:length(S.profile_datenum)
      S.profile_n(i) = sum(S.profile_id==i);
  end
  
if OPT.plot  
   edges = [0 1 3 10 30 100 300 1000 3e3 1e4];
   N = histc(S.profile_n,edges)
   bar(edges,N,'histc')
   set(gca,'xscale','log')  
end
  
  %% split profiles that take too long, these should be treated as trajectories
  
  % TODO

%%
% ctd_2000_-_2002.dia - 910 locations when eps=0
% ctd_2000_-_2002.dia -  56 locations when eps=0.01 ~ 1 km
% ctd_2000_-_2002.dia -  40 locations when eps=0.015
% ctd_2000_-_2002.dia -  36 locations when eps=0.02 ~ 2 km
        
%% we choose 5 min as seperate CTD cast
% t.dt_bnds = [0 [1 2 5 10 20]/24/3600 [1 2 5 10 20]/24/60 [1 2 5 10 20]/24 1 2 5 10 20];
% t.dt = histc(diff(S.datenum),t.dt_bnds)
% t.dt

%        69946 1 sec.
%        82693 2
%          137 5
%            1 10
%            0 20

%            0 1 min.
%            0 2
%            0 5 <<<<<<<
%            0 10
%           20 20

%          279 1 hour
%          124 2
%          165 5
%           33 10
%           59 20

%           10 day
%           14
%           28
%           54
%           16
%            0        
