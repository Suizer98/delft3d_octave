%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16769 $
%$Date: 2020-11-05 18:40:08 +0800 (Thu, 05 Nov 2020) $
%$Author: chavarri $
%$Id: add_one_groyn.m 16769 2020-11-05 10:40:08Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/bed_level_flume/add_one_groyn.m $
%

function z_out=add_one_groyn(geom,x_rel,y_rel,z_rel)

%% RENAME

% v2struct(geom) %rename

%external
B_groyn=geom.B_groyn;
L_groyn=geom.L_groyn;
s_us_groyn=geom.s_us_groyn;
h_groyn=geom.h_groyn;
s_n2_groyn=geom.s_n2_groyn;
s_n1_groyn=geom.s_n1_groyn;
L_top_groyn=geom.L_top_groyn;

%local
tan_us=tan(s_us_groyn);
L_s_us=h_groyn/tan_us; %length of the upsloping part
L_s_ds=L_groyn-L_top_groyn-L_s_us; %length of the downsloping part
B_inter_n_faces=(s_n2_groyn*B_groyn-h_groyn)/(s_n2_groyn-s_n1_groyn); %transverse length to intersection point between transverse sloping faces

%% CALC

%trapezoid uniform in x
if x_rel<=L_s_us
    z=z_rel+x_rel*tan_us;
elseif x_rel<=L_s_us+L_top_groyn
    z=z_rel+h_groyn;
elseif x_rel<=L_s_us+L_top_groyn+L_s_ds %=L_groyn
    z=z_rel-h_groyn/L_s_ds*(x_rel-L_groyn);
else
    error('you should not get here')    
end

%substratct transverse slope 
if y_rel<=B_inter_n_faces
    h_max=-s_n1_groyn*y_rel+h_groyn+z_rel;
    if z>h_max
        z=h_max;
    end
elseif y_rel<=B_groyn
    h_max=-s_n2_groyn*(y_rel-B_groyn)+z_rel;
    if z>h_max
        z=h_max;
    end
else
    error('you should not get here')    
end

%output
z_out=z;

end