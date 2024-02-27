%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17201 $
%$Date: 2021-04-17 01:15:25 +0800 (Sat, 17 Apr 2021) $
%$Author: chavarri $
%$Id: D3D_plot_from_file.m 17201 2021-04-16 17:15:25Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_plot_from_file.m $
%
%Runs the plotting routine reading the input from a matlab script
%
%INPUT:
%   -path_input: path to the matlab script (char)

function out_read=D3D_plot_from_file(path_input)

messageOut(NaN,'start plotting')
[def,simdef,in_read]=D3D_read_input_m(path_input);
out_read=D3D_plot(simdef,in_read,def);
messageOut(NaN,'finished plotting')

end %function