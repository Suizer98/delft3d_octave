function P = ctd_timeSeriesProfile(S,ind)
%ctd_timeSeriesProfile merge timeseries of profiles at 1 location from random collection of profile/locations
%
%  P = ctd_timeSeriesProfile(S,ind)
%
% where S = ctd_struct(..) and ind is a series of indices
%.e.g. ind = (S.station_id==ist)
%
% P can be plotted with donar.ctd_timeSeriesProfile_plot()
%
%See also: ctd_struct, ctd_timeSeriesProfile_plot

   % copy all profile id for this semi-fixed positions,
   % we cannot always assume 1 profile to be instantaneous
   % as sometimes CTD is used as ferrybox/scanfish:
   % left to drift at constant z for a while
   % e.g. profile_id=311: 01-Feb-2001 08:39:42 - 01-Feb-2001 09:21:51
   % e.g. profile_id=312: 01-Feb-2001 12:45:27 - 01-Feb-2001 12:57:37
   % e.g. profile_id=313: 02-Feb-2001 05:17:02 - 02-Feb-2001 05:58:01            
   %
   % So we also have to keep all original (mostly redundant) 
   % time and place information, to see duration of extended cast
   % and boat drift (and perhaps it even had it's engine on) 
   
   P.profile_id  = unique(S.profile_id((ind)));
   nt = length(P.profile_id);
   P.profile_n       = zeros(nt,1);
   P.profile_lon     = zeros(nt,1);
   P.profile_lat     = zeros(nt,1);
   P.profile_datenum = zeros(nt,1);
   
   for it=1:nt 
       ind1 = find(S.profile_id==P.profile_id(it));
       P.profile_n  (it)     = length(ind1);
       P.profile_lon(it)     = mean(S.lon(ind1));
       P.profile_lat(it)     = mean(S.lat(ind1));
       P.profile_datenum(it) = mean(S.datenum(ind1));
   end
   
   % copy all profiles at one location into 2D [z x t] array
   %  = ragged reshape
   nz = max(P.profile_n);
   flds2copy = {'lon','lat','z','datenum','data','block'};
   for ifld = 1:length(flds2copy)
     fld = flds2copy{ifld};
     P.(fld) = nan(nz,nt);   
   end            
   for it=1:nt
     ind1 = find(S.profile_id==P.profile_id(it));
     nz1 = length(ind1);
     for ifld = 1:length(flds2copy)
       fld = flds2copy{ifld};
       P.(fld)(1:nz1,it) = S.(fld)(ind1);
     end
   end