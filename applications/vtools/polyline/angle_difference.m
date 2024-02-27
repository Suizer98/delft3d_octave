%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17804 $
%$Date: 2022-03-02 16:37:25 +0800 (Wed, 02 Mar 2022) $
%$Author: chavarri $
%$Id: angle_difference.m 17804 2022-03-02 08:37:25Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/angle_difference.m $
%

function angle_diff=angle_difference(angle_a,angle_b)

if numel(angle_a)==1
    angle_a=angle_a.*ones(size(angle_b));
elseif numel(angle_b)==1
    angle_b=angle_b.*ones(size(angle_a));
end

angle_diff=angle_b-angle_a;
bol_ss=abs(angle_diff)>pi; 
angle_diff(bol_ss)=2*pi-abs(angle_diff(bol_ss));

end %function

