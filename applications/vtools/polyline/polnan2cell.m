%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17478 $
%$Date: 2021-09-09 23:44:11 +0800 (Thu, 09 Sep 2021) $
%$Author: chavarri $
%$Id: polnan2cell.m 17478 2021-09-09 15:44:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/polnan2cell.m $
%

function piles=polnan2cell(piles_nan)

nan_p=isnan(piles_nan(:,1));
nx=size(piles_nan,1);
idx_n=[0;find(nan_p);nx+1];
np=sum(nan_p)+1;
piles=cell(np,1);
for kp=1:np
    piles{kp,1}=piles_nan(idx_n(kp)+1:idx_n(kp+1)-1,:);
end
