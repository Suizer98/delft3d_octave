%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17760 $
%$Date: 2022-02-14 17:51:28 +0800 (Mon, 14 Feb 2022) $
%$Author: chavarri $
%$Id: polcell2nan.m 17760 2022-02-14 09:51:28Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/polcell2nan.m $
%

function pol_nan=polcell2nan(pol_cell)

np=numel(pol_cell);
pol_nan=[];
ndim=size(pol_cell{1,1},2);
nanm=NaN(1,ndim);
for kp=1:np
    pol_nan=cat(1,pol_nan,pol_cell{kp,1},nanm);
end
