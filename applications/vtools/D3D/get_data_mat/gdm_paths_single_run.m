%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: gdm_paths_single_run.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_paths_single_run.m $
%
%Generate paths of single run

function [simdef,leg_str]=gdm_paths_single_run(fid_log,in_plot,ks,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'disp',1);

parse(parin,varargin{:});

do_disp=parin.Results.disp;

%% CALC

fdir_sim=in_plot.fdir_sim{ks};
simdef=simulation_paths(fdir_sim,in_plot);
if do_disp
    messageOut(fid_log,sprintf('Simulation: %s',simdef.file.runid))	
end
if isfield(in_plot,'str_sim')
    leg_str=in_plot.str_sim{ks};
else
    leg_str='';
end

end %function 