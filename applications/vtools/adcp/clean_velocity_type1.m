%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17478 $
%$Date: 2021-09-09 23:44:11 +0800 (Thu, 09 Sep 2021) $
%$Author: chavarri $
%$Id: clean_velocity_type1.m 17478 2021-09-09 15:44:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/adcp/clean_velocity_type1.m $
%

function vmag=clean_velocity_type1(vmag,varargin)

flg.unit='cm';
flg=setproperty(flg,varargin);

vmag(vmag==-32768)=NaN;
switch flg.unit
    case 'cm'
        vmag=vmag./100;
    otherwise
        %left unchanged
end

end