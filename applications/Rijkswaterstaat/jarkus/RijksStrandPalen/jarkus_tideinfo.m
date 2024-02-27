function varargout = jarkus_tideinfo(tidefile)
%JARKUS_TIDEINFO  load jarkus_tideinfo table
%
%See also: jarkus

if nargin==0
   tidefile = [mfilename('fullpath'),'.txt'];
end

    raw                           = load(tidefile);
    
    tideinfo.areaCode             = raw(:,1);
    tideinfo.alongshoreCoordinate = raw(:,2); 
    tideinfo.MHW                  = raw(:,3);
    tideinfo.LMW                  = raw(:,4);

varargout = {tideinfo};