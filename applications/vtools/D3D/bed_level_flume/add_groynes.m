%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16769 $
%$Date: 2020-11-05 18:40:08 +0800 (Thu, 05 Nov 2020) $
%$Author: chavarri $
%$Id: add_groynes.m 16769 2020-11-05 10:40:08Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/bed_level_flume/add_groynes.m $
%

function z_out=add_groynes(geom,x,y,z_in)

%% RENAME

% v2struct(geom) %expensive

%external
L_to_first_groyn=geom.L_to_first_groyn;
L_between_groynes=geom.L_between_groynes;
B_floodplane=geom.B_floodplane;
B_groyn=geom.B_groyn;
L_groyn=geom.L_groyn;
L_to_downstream_end=geom.L_to_downstream_end;

%% CALC

xfrac=rem(x-L_to_first_groyn,L_between_groynes);
groyn_field_number=floor((x-L_to_first_groyn)/L_between_groynes); 

if x<=L_to_first_groyn || y<=B_floodplane || y>=B_floodplane+B_groyn || x>=L_to_downstream_end
    z_out=z_in;
else
    if xfrac<=L_groyn
        x_rel=x-L_to_first_groyn-groyn_field_number*L_between_groynes;
        y_rel=y-B_floodplane;
        z_rel=z_in;
        z_out=add_one_groyn(geom,x_rel,y_rel,z_rel);
    else
        z_out=z_in;
    end
end

end %function