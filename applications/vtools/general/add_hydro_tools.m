%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17444 $
%$Date: 2021-08-03 03:26:54 +0800 (Tue, 03 Aug 2021) $
%$Author: chavarri $
%$Id: add_hydro_tools.m 17444 2021-08-02 19:26:54Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/add_hydro_tools.m $
%
%Add paths of hydro tools

function add_hydro_tools(path_hyd)

fid_log=NaN;
if exist('update_hydro_tools','file')~=2
    messageOut(fid_log,sprintf('Start adding repository '));
    addpath(genpath(path_hyd)); 
else
    messageOut(fid_log,sprintf('Repository already exists'));
end