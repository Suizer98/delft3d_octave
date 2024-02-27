%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18353 $
%$Date: 2022-09-08 19:39:21 +0800 (Thu, 08 Sep 2022) $
%$Author: chavarri $
%$Id: D3D_status.m 18353 2022-09-08 11:39:21Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_status.m $
%
%INPUT
%   simdef: several options:
%       -simdef structure
%       -cell array with path to simulation folder
%
%OUTPUT:
%   sta=1: not started
%   sta=2: running
%   sta=3: done
%   sta=4: interrupted (did not reach final time but exit controlled)

function [sta,time_comp,tgen,version,tim_ver,source,processes]=D3D_status(simdef,varargin)

%% PARSE

%% CASE

if iscell(simdef)
    ns=numel(simdef);
    sta=NaN(ns,1);
    time_comp=NaT(ns,1)-datetime(2000,1,1); %duration
    tgen=NaT(ns,1);
    version=cell(ns,1);
    tim_ver=NaT(ns,1);
    source=cell(ns,1);
    processes=NaN(ns,1);
    for ks=1:ns
        if isfolder(simdef{ks})
            simdef_true.D3D.dire_sim=simdef{ks};
            [sta(ks),time_comp(ks),tgen(ks),version{ks},tim_ver(ks),source{ks}]=D3D_status(simdef_true,varargin{:});
        else
            error('do')
        end
    end
    return
end

%% CALC

sta=NaN;
time_comp=NaT-datetime(2000,1,1); %duration
tgen=NaT;
version='';
tim_ver=NaT;
source='';
processes=NaN;

simdef=D3D_simpath(simdef);

%this can be improved seeing whether a map and his file are requested
if isfield(simdef.file,'map')==0 && isfield(simdef.file,'his')==0
    sta=1; 
    return
end

is_inter=D3D_is_interrupt(simdef,varargin);
if is_inter
    sta=4;
    if simdef.D3D.structure==2
        time_comp=D3D_computation_time(simdef.file.dia);
        [tgen,version,tim_ver,source]=D3D_version(simdef,varargin);
    end
    return 
end

is_done=D3D_is_done(simdef,varargin);

if is_done
    sta=3;
    [time_comp,~,~,processes]=D3D_computation_time(simdef.file.dia);
    [tgen,version,tim_ver,source]=D3D_version(simdef,varargin);
    return 
end

sta=2; 
[tgen,version,tim_ver,source]=D3D_version(simdef,varargin);

end %function