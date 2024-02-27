%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17478 $
%$Date: 2021-09-09 23:44:11 +0800 (Thu, 09 Sep 2021) $
%$Author: chavarri $
%$Id: adcp_projectVelocity.m 17478 2021-09-09 15:44:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/adcp/adcp_projectVelocity.m $
%

function [vpara,vperp]=adcp_projectVelocity(data_block,idx_out2,angle_track,check_reverse)

% vmag=[data_block(~idx_out2).vmag];
veast=[data_block(~idx_out2).veast];
vnorth=[data_block(~idx_out2).vnorth];
% vvert=[data_block(~idx_out2).vvert];

vpara=veast.*cos(angle_track')+vnorth.*sin(angle_track');
vperp=veast.*sin(angle_track')-vnorth.*cos(angle_track');

%reverse direction
if check_reverse
    if nanmean(vperp(:))<0
       angle_track=angle_track+pi;
       vperp=-vperp;
       vpara=-vpara;
    end
end