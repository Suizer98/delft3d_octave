%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 17437 $
%$Date: 2021-08-02 11:19:02 +0800 (Mon, 02 Aug 2021) $
%$Author: chavarri $
%$Id: bed_flux_general.m 17437 2021-08-02 03:19:02Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/bed_flux_general.m $
%
%bed_level_update updates the bed elevation
%
%etab_new=bed_level_update(etab,qbk,bc,input,fid_log,kt)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -
%
%HISTORY:
%201106
%   -V. Created for the first time.
%
%210315
%   -V. New implementation at edges.

function bed_flux=bed_flux_general(input,Qb_edg,B_edg,c_edg,etab,dt)

%% 
%% RENAME
%%

nx=input.mdv.nx;
ne=nx+1;
dx=input.grd.dx;
input.mdv.fluxtype=input.mor.fluxtype; %we use the same function as for flow

%% CALC

switch input.mor.scheme
    case 2 %Boorsboom
        %Firts useful flux is for node 2. 
        %The needed edges are at 2-0.5=1.5 (i.e., edge 2) and 2+0.5 (i.e., edge 3)
        %
        %
        % |---x---|---x---|---x---|---x---|---x---|
        % 1       2       3       4       5       6 edges (cell edge)
        %     1       2       3       4       5     nodes (cell centre)
        %
        r=NaN(1,nx); %nodes
        r(2:nx-1)=(etab(2:nx-1)-etab(1:nx-2))./(etab(3:nx)-etab(2:nx-1)+1e-10); %useful double(1,nx-2) for cell centres 2:nx-1. epsilon to prevent NaN when flat
        sigma_b=c_edg.*dt./dx; %useful double(1,nx+1) for cell edges 1:nx+1. c_edg must account for MorFac/cb
        phi_val=NaN(1,nx);
        phi_val(2:nx-1)=phi_func(r(2:nx-1),input); %useful double(1,nx-2) for cell centres 2:nx-1.
        flux_edg=NaN(1,ne);
        flux_edg(3:ne-1)=Qb_edg(3:ne-1)./B_edg(3:ne-1)+c_edg(3:ne-1).*0.5.*((1-sigma_b(3:ne-1)).*phi_val(2:nx-1)-1).*(etab(3:nx)-etab(2:nx-1)); %useful double(1,nx-2) for cell edges 2:nx-1
%         flux_edg(2:ne-2)=Qb_edg(2:ne-2)./B_edg(2:ne-2); %useful double(1,nx-2) for cell edges 2:nx-1
        bed_flux=NaN(1,nx);
        bed_flux(3:nx-1)=flux_edg(4:ne-1)-flux_edg(3:ne-2);
end

end %function

%%
%% FUNCTIONS
%%

%%
%% OLD
%%

% idx_edg=2:nx-1; %[2,nx-1] are updated with this scheme. 

% fp05_p=f_flux_p(input,2:1:nx+1,Qb_edg./B_edg,c_edg,etab,dt); %f_(n+0.5) when upwind positive. Fluxes at edges 2:nx+1 (e.g. 2:6)
% fm05_p=f_flux_p(input,1:1:nx  ,Qb_edg./B_edg,c_edg,etab,dt); %f_(n-0.5) when upwind positive. Fluxes at edges 1:nx   (e.g. 1:5)

% fm_p=f_flux_p(input,1:1:nx,Qb_edg./B_edg,c_edg,etab,dt); 

%bed_flux has same dimensions as the nodes, although not all are useful

% bed_flux(:)=fp05_p-fm05_p;
% 
% function r=f_r(vm,v)
% % r=(v(vm+1)-v(vm))./(v(vm)-v(vm-1)); %epsilon to prevent NaN when flat
% % r=(v(vm+1)-v(vm)+1e-10)./(v(vm)-v(vm-1)+1e-10); %epsilon to prevent NaN when flat
% r=(v(vm)-v(vm-1))./(v(vm+1)-v(vm)+1e-10); %epsilon to prevent NaN when flat
% end
% 
% function sigma_b=f_sigma_b(input,c_edg,dt)
% % sigma_b=input.mor.MorFac.*c_edg.*dt./(1-input.mor.porosity)./input.grd.dx;
% sigma_b=c_edg.*dt./input.grd.dx; %c_edg is already scaled with MorFac/cb
% end
% 
% function f_flux_p=f_flux_p(input,vm,Qb_edg,c_edg,etab,dt)
% 
% input.mdv.fluxtype=input.mor.fluxtype; %we use the same function as for flow
% 
% switch input.mor.scheme
%     case 2 %Borsboom
%         r=f_r(vm,etab);
%         sigma_b=f_sigma_b(input,c_edg(vm),dt);
%         f_flux_p=Qb_edg(vm)+c_edg(vm).*0.5.*((1-sigma_b).*phi_func(r,input)-1).*(etab(vm+1)-etab(vm));
% end %switch
% 
% end %function
