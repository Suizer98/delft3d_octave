%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17877 $
%$Date: 2022-03-31 19:06:18 +0800 (Thu, 31 Mar 2022) $
%$Author: chavarri $
%$Id: sal2cl.m 17877 2022-03-31 11:06:18Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/sal2cl.m $
%
% 1: convert [psu]    -> [mgCl/l]
%-1: convert [mgCl/l] -> [psu]

function out_val=sal2cl(flg_conv,in_val)

switch flg_conv
    case 1 %sal2cl
        out_val=in_val./1.80655*1000;
    case -1 %cl2sal
        out_val=in_val.*1.80655/1000;
end

end %function