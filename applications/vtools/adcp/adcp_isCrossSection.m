%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17478 $
%$Date: 2021-09-09 23:44:11 +0800 (Thu, 09 Sep 2021) $
%$Author: chavarri $
%$Id: adcp_isCrossSection.m 17478 2021-09-09 15:44:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/adcp/adcp_isCrossSection.m $
%

function isCross=adcp_isCrossSection(s,varargin)

flg.limit_cs=Inf;
flg=setproperty(flg,varargin);

isCross=1;
if s(end)>flg.limit_cs
    isCross=0;
end

end