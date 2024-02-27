%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17535 $
%$Date: 2021-10-30 03:37:36 +0800 (Sat, 30 Oct 2021) $
%$Author: chavarri $
%$Id: RWS_location_clear.m 17535 2021-10-29 19:37:36Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/RWS_location_clear.m $
%

function [str_sta,str_found]=RWS_location_clear(stationlist)

if ~iscell(stationlist)
    stationlist_c{1,1}=stationlist;
    stationlist=stationlist_c;
end

ns=numel(stationlist);
str_sta=cell(1,ns);
str_found=false(1,ns);
for ks=1:ns
[str_sta{ks},str_found(ks)]=waterDictionary(stationlist{ks},NaN,'normal','dict','rwsNames.csv','stationnodot',false);
end

end %function