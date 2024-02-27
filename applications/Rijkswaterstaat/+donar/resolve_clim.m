function clim = resolve_clim(WNS)
%resolve_clim get clim for a WNS
%
% clim = resolve_clim(WNS) where NaN mean no valid range is present.
%
%See also: 


   tmp = donar.resolve_wns(WNS,'request','struct');
   if isempty(tmp.valid_min{1})
       tmp.valid_min    = nan;
   else
       tmp.valid_min    = str2num(tmp.valid_min{1});
   end
   if isempty(tmp.valid_max{1})
       tmp.valid_max    = nan;
   else
       tmp.valid_max    = str2num(tmp.valid_max{1});
   end
   
   clim = [tmp.valid_min tmp.valid_max];