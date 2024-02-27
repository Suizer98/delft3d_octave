%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17599 $
%$Date: 2021-11-19 04:17:32 +0800 (Fri, 19 Nov 2021) $
%$Author: chavarri $
%$Id: D3D_fxw_analysis.m 17599 2021-11-18 20:17:32Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_fxw_analysis.m $
%
%Analysis of fixed weir
%
%[val_u,val_d,scen_u,idx_h,idx_u,idx_etaw,F_crest,F_weir_height,cord,F_crest_width,F_slope_right,F_slope_left]=D3D_fxw_analysis(fdir_sim,varargin)
%
%INPUT:
%   -

function [val_u,val_d,scen_u,idx_h,idx_u,idx_etaw,F_crest,F_weir_height,cord,F_crest_width,F_slope_right,F_slope_left]=D3D_fxw_analysis(fdir_sim,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fpath_fxw','');
addOptional(parin,'pos_v',[0,1]);
addOptional(parin,'eps_g',5e-3);

parse(parin,varargin{:});

fpath_fxw=parin.Results.fpath_fxw;
pos_v=parin.Results.pos_v;
if pos_v(1)~=0
    warning('The first position to analyze must be 0 (i.e., at the groyne). I am adding it.')
    pos_v=[0;pos_v];
end
eps_g=parin.Results.eps_g;

%% CALC

np=numel(pos_v);
     
%variables to read
var_name_v={'mesh2d_waterdepth','u_para','mesh2d_s1'};
idx_h=1;
idx_u=2;
idx_etaw=3;

nv=numel(var_name_v);

simdef.D3D.dire_sim=fdir_sim;
simdef=D3D_simpath(simdef);
path_map=simdef.file.map;

%times
[~,~,time_dnum,~]=D3D_results_time(path_map,0,NaN);

%groynes position
if isempty(fpath_fxw)
    fpath_fxw=simdef.file.fxw;
end

[F_crest,F_weir_height,cord,F_crest_width,F_slope_right,F_slope_left]=D3D_interpolate_fxw(fpath_fxw);
ng=numel(F_crest);

%prallocate
val_u=cell(ng,1);
val_d=val_u;
scen_u=val_u;
scen_d=val_u;

%preallocate
%     kg=1;
%     aux=get_vars_cd(path_map,time_dnum,cord{kg},var_name_v{1});
%     nc=numel(aux);
% NaN(nc,ng,np,nv);
% val_u{ks}=cell(ng,1);
% val_d{ks}=val_u{ks};
% scen_u{ks}=val_u{ks};
% scen_d{ks}=val_u{ks};

%loop on groyne
for kg=1:ng

    %loop on position
    for kp=1:np

        %ATT!
        %what is upstream and downstream depends on the orientation of the line.
        cord_mod=cord{kg};
        cord_mod(:,1)=cord_mod(:,1)-eps_g; %prevent lines passing over grid lines
        cord_mod(:,2)=cord_mod(:,2)+[-eps_g;eps_g]; %prevent lines passing over grid lines
        [perp_us,perp_ds]=perpendicular_polyline(cord_mod,2,pos_v(kp)); 

        %upstream
        for kv=1:nv
            [val_u{kg}{kp}(:,kv),scen_u{kg}{kp}]=get_vars_cd(path_map,time_dnum,perp_us,var_name_v{kv});
        end

        %downstream
        for kv=1:nv
            [val_d{kg}{kp}(:,kv),scen_d{kg}{kp}]=get_vars_cd(path_map,time_dnum,perp_ds,var_name_v{kv});
        end
        messageOut(NaN,sprintf('Done %4.2f %% %4.2f %%',kp/np*100,kg/ng*100));
    end %kp
end %ng

end %function