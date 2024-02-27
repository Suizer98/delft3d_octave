%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17643 $
%$Date: 2021-12-11 00:45:07 +0800 (Sat, 11 Dec 2021) $
%$Author: chavarri $
%$Id: D3D_cd_analysis.m 17643 2021-12-10 16:45:07Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_cd_analysis.m $
%
%Analysis of fixed weir
%
%[scen_u,q,c_dd,c_dd_V1,c_dm_T1,c_dr_T1,c_dm_M1,c_dr_M1,c_dd_V2,c_dm_T2,c_dr_T2,c_dm_M2,c_dr_M2,pos_v,crest_level]=D3D_cd_analysis(val_u,val_d,scen_u,idx_h,idx_u,idx_etaw,F_crest,F_weir_height,F_crest_width,F_slope_right,F_slope_left)
%
%INPUT:
%   -

function [scen_u,q,c_dd,c_dd_V1,c_dm_T1,c_dr_T1,c_dm_M1,c_dr_M1,c_dd_V2,c_dm_T2,c_dr_T2,c_dm_M2,c_dr_M2,crest_level,S,E_u,E_d]=D3D_cd_analysis(val_u,val_d,scen_u,idx_h,idx_u,idx_etaw,F_crest,F_weir_height,F_crest_width,F_slope_right,F_slope_left)

g=9.81;

ng=numel(val_u);
np=numel(val_u{1});

%preallocate
c_dd=cell(ng,1);
c_dd_V1=c_dd;
c_dm_M1=c_dd;
c_dm_T1=c_dd;
c_dr_M1=c_dd;
c_dr_T1=c_dd;
c_dd_V2=c_dd;
c_dm_M2=c_dd;
c_dm_T2=c_dd;
c_dr_M2=c_dd;
c_dr_T2=c_dd;
crest_level=c_dd;
S=c_dd;
q=c_dd;
E_u=c_dd;
E_d=c_dd;
for kg=1:ng

    kp=1; %at crest

    %This is not general enough. If the grid would be finer d/s, E_d would
    %have a different size than E_u and you could not operate. 
    %The solution is to interpolate each value depending on its scen on a common scen

    crest_level_int=F_crest{kg}(scen_u{kg}{kp});
%         crest_width_int=F_crest_width{kg}(scen_u{kg}{kp});
%         slope_right_int=F_slope_right{kg}(scen_u{kg}{kp});
%         slope_left_int=F_slope_left{kg}(scen_u{kg}{kp});
%         weir_height_int=F_weir_height{kg}(scen_u{kg}{kp});

    q_c=val_u{kg}{kp}(:,idx_h).*val_u{kg}{kp}(:,idx_u); %q=u*h
    hT_u=val_u{kg}{kp}(:,idx_etaw)-crest_level_int; %water level upstream relative to crest height
    E_u_c=hT_u+val_u{kg}{kp}(:,idx_u).^2/2/g; %energy upstream relative to crest height
    c_dd_c=q_c.*3./2./sqrt(2*g).*E_u_c.^(-3/2); %C_{dd} measured

    for kp=1:np

        q{kg}{kp}=val_u{kg}{kp}(:,idx_h).*val_u{kg}{kp}(:,idx_u); %q=u*h

        crest_level_int=F_crest{kg}(scen_u{kg}{kp});
        crest_width_int=F_crest_width{kg}(scen_u{kg}{kp});
        slope_right_int=F_slope_right{kg}(scen_u{kg}{kp});
        slope_left_int=F_slope_left{kg}(scen_u{kg}{kp});
        weir_height_int=F_weir_height{kg}(scen_u{kg}{kp});

        crest_level{kg}{kp}=crest_level_int;

        hT_u=val_u{kg}{kp}(:,idx_etaw)-crest_level_int; %water level upstream relative to crest height
        E_u{kg}{kp}=hT_u+val_u{kg}{kp}(:,idx_u).^2/2/g; %energy upstream relative to crest height

        hT_d=val_d{kg}{kp}(:,idx_etaw)-crest_level_int; %water level downstream relative to crest height
        E_d{kg}{kp}=hT_d+val_d{kg}{kp}(:,idx_u).^2/2/g; %energy downstream relative to crest height

        c_dd{kg}{kp}=q_c.*3./2./sqrt(2*g).*E_u{kg}{kp}.^(-3/2); %C_{dd} measured

        %Villemonte
        OPT.type=1;
        OPT.d1=weir_height_int;

        [c_dd_V1{kg}{kp},c_dm_T1{kg}{kp},c_dr_T1{kg}{kp}]=Villemonte_cdd(E_u_c,E_d{kg}{kp},OPT);

        c_dm_M1{kg}{kp}=c_dd_c./c_dr_T1{kg}{kp};
        c_dr_M1{kg}{kp}=c_dd_c./c_dm_T1{kg}{kp};

        %extended Villemonte
        OPT.type=2;
        OPT.m1=slope_left_int; %user-specified ramp of the upwind slope toward the weir ratio of ramp length and height, [ ? ], default 4.0
        OPT.m2=slope_right_int; %user-specified ramp of the downwind slope from the weir ratio of ramp length and height [ ? ], default 4.0
        OPT.L=crest_width_int; %L crest is the length of the weir’s crest [ m ] in the direction across the weir (i.e., in the direction of the flow).

        [c_dd_V2{kg}{kp},c_dm_T2{kg}{kp},c_dr_T2{kg}{kp},S{kg}{kp}]=Villemonte_cdd(E_u_c,E_d{kg}{kp},OPT);

        c_dm_M2{kg}{kp}=c_dd_c./c_dr_T2{kg}{kp};
        c_dr_M2{kg}{kp}=c_dd_c./c_dm_T2{kg}{kp};
    end %kp
end %kg