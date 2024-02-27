%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17508 $
%$Date: 2021-09-30 17:17:04 +0800 (Thu, 30 Sep 2021) $
%$Author: chavarri $
%$Id: D3D_convert_station_names_obs_normal.m 17508 2021-09-30 09:17:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_convert_station_names_obs_normal.m $
%

function [str_sta,str_found]=D3D_convert_station_names_obs_normal(sss)

ns=numel(sss);
str_sta=cell(1,ns);
str_found=false(1,ns);
for ks=1:ns
[str_sta{ks},str_found(ks)]=waterDictionary(sss{ks},NaN,'normal','dict','rwsNames.csv','stationnodot',false);
end