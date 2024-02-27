function [ constituents ] = t_tide(noos_ascii, period, format)
%t_tide     tidal timeseries analysis from noos file
%
% Input:
%   noos_ascii   = text/csv (NOOS format)
%   period       = text/csv (NOOS format)
%   format       = string
%
% Output:
%   constituents = text/html, text/plain, text/xml, application/netcdf
%
%See also: t_tide, noos_read, noos_write, t_tide2html

%% t_tide keywords

   OPT.period        = [];
   OPT.synth         = 2;
   OPT.sort          = 'freq';
   OPT.country       = '';
   OPT.units         = '';
   
% reserved WPS keyword

   OPT.format        = 'text/xml'; % http://en.wikipedia.org/wiki/Internet_media_type
   
% call

   WPS = setproperty(OPT,varargin);

% # Timezone    : MET
% #------------------------------------------------------
% 200709010000   -0.387653201818466
% 200709010010   -0.395031750202179
% 200709010020   -0.407451331615448
% 200709010030   -0.414252400398254
% 200709010040   -0.425763547420502
% 200709010050   -0.43956795334816
  
   [time, data, headerlines] = noos_read(noos_ascii);

   M = matroos_noos_header(headerlines);
   
   OPT2     = OPT;
   OPT2     = rmfield(OPT2,'format');
   OPT2     = rmfield(OPT2,'country');
   OPT2     = rmfield(OPT2,'units');   
   OPT2.lat = M.lat;

   if strcmpi(WPS.format,'text/plain') % native t_tide ascii garbage
      OPT2.ascfile  = 't_tide.asc';
   end
   %%
   [D,fit] = t_tide2struc(time,data,OPT2);

% IHO xml keywords	 

   D.name                = M.loc;
   D.country             = OPT.country; % not in NOOS
   D.position.latitude   = M.lat;
   D.position.longitude  = M.lon;
   D.timeZone            = M.timezone;
   D.units               = OPT.units;   % not in NOOS

  %D.observationStart    = ' '; % in struc from period
  %D.observationEnd      = ' '; % in struc from period
  %D.comments            = ' '; % ?
%%
if strcmpi(WPS.format,'text/plain') % native t_tide ascii garbage

   constituents = loadstr(OPT2.ascfile);

elseif strcmpi(WPS.format,'text/xml')

   constituents  = t_tide2xml (D);

elseif strcmpi(WPS.format,'application/netcdf')

   t_tide2nc  (D,'filename','t_tide.nc');
   warning('find a way to send t_tide.nc back to user')
   % implement base 64 encoding
   % or copy to local folder
   
   constituents = 'ok';
   
else %if strcmpi(WPS.format,'text/html') % default
   
   constituents  = t_tide2html(D);
   
end

% send file back: map local link to weblink ??