%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: tiles_zoom.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/tiles_zoom.m $
%

function tz1=tiles_zoom(dx)

if dx<100
    tz1=16;
elseif dx<10e3
    tz1=14;
elseif dx<20e3
    tz1=13;
elseif dx<100e3
    tz1=9;
elseif dx<500e3
    tz1=8;
else
    tz1=1;
end
end %function