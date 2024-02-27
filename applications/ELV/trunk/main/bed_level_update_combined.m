
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 17448 $
%$Date: 2021-08-06 14:52:27 +0800 (Fri, 06 Aug 2021) $
%$Author: chavarri $
%$Id: bed_level_update_combined.m 17448 2021-08-06 06:52:27Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/bed_level_update_combined.m $
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
%201102
%   -V. Created for the first time.
%

function etab_new=bed_level_update_combined(input,etab,Qb0,Qb,beta,celerities,u,u_edg,Qb_edg,celerities_edg,beta_edg)

%%
%% RENAME
%%

dx=input.grd.dx;
dt=input.mdv.dt;    
MorFac=input.mor.MorFac;
cb=1-input.mor.porosity;
nx=input.mdv.nx; %number of cells
% nf=input.mdv.nf; 
% UpwFac=input.mdv.UpwFac;
% bc_interp_type=input.mdv.bc_interp_type;
B=input.grd.B;
B_edg=input.grd.B_edg;

%%
%% CALC
%%

% UpwFac = 1-(Qb<0); %sets the UpwFac to 1 if flow comes from left, and to 0 if flow comes from right [1,nx] double

etab_new=NaN(1,nx);

%upstream node always FTBS
if input.bcm.type==4
    etab_new(1,1)=etab(1,1);
else
    flux_bed=bed_flux_BS([Qb0,Qb(1)],B(1:2));
    etab_new(1,1)      = etab(1,1)      - MorFac * dt /cb /beta(1,1)/(dx/2) * flux_bed;
end
        
switch input.mor.scheme
    case 1 %FTBS
        flux_bed=bed_flux_BS(Qb,B);
        etab_new(1,2:nx)=etab(1,2:nx)-MorFac*dt./cb./beta(1,2:nx)./(dx).* flux_bed;
    case 2 %Borsboom
        %second cell is BS
        flux_bed=bed_flux_BS(Qb(2:3),B(2:3));
        etab_new(1,2)      = etab(1,2)      - MorFac * dt /cb ./beta(1,2)./(dx) .* flux_bed;
        
        %rest is Borsboom
        pmm(2,:)=beta_edg;
        input_loc=input;
        input_loc.mdv.flowtype=0; %for taking bed celerity
        c_edg=celerities4CFL(u_edg,NaN,celerities_edg,pmm,NaN,input_loc,NaN,NaN); %dimensional and scaled with MF/cb
                            
        flux_bed=bed_flux_general(input,Qb_edg,B_edg,c_edg,etab,dt);
        etab_new(1,3:nx-1)=etab(1,3:nx-1)-MorFac*dt./cb./beta(1,3:nx-1)./(dx).* flux_bed(1,3:nx-1);
%         etab_new(1,3:nx-1)=etab(1,3:nx-1)-MorFac*dt./cb./beta(1,3:nx-1)./(dx).* flux_bed;
        
        %last 2 cells are BS
        flux_bed=bed_flux_BS(Qb(end-2:end),B(end-2:end));
        etab_new(1,nx-1:nx)      = etab(1,nx-1:nx)      - MorFac * dt /cb ./beta(1,nx-1:nx)./(dx) .* flux_bed;
        
        %DEPRECATED: all higher order without CFL dependent correction are
        %unstable with Euler forward. 
%     case 3 %QUICK
%         %second cell is BS
%         flux_bed=bed_flux_BS(Qb(1:2),B(2:3));
%         etab_new(1,2)      = etab(1,2)      - MorFac * dt /cb /beta(1,2)/(dx) * flux_bed;
%         
%         %rest is QUICK
%         flux_bed=bed_flux_QUICK(Qb,B);
%         etab_new(1,3:nx-1)=etab(1,3:nx-1)-MorFac*dt./cb./beta(1,3:nx-1)./(dx).* flux_bed;
%         
%         %last cell is BS
%         flux_bed=bed_flux_BS(Qb(end-1:end),B(end-1:end));
%         etab_new(1,nx)      = etab(1,nx)      - MorFac * dt /cb /beta(1,nx)/(dx) * flux_bed;
%     case 4
%         %second cell is BS
%         flux_bed=bed_flux_BS(Qb(1:2),B(2:3));
%         etab_new(1,2)      = etab(1,2)      - MorFac * dt /cb /beta(1,2)/(dx) * flux_bed;
%         
%         %rest is flux limiter
%         flux_bed=bed_flux_limiter(input,Qb,B);
%         etab_new(1,3:nx-1)=etab(1,3:nx-1)-MorFac*dt./cb./beta(1,3:nx-1)./(dx).* flux_bed;
%         
%         %last cell is BS
%         flux_bed=bed_flux_BS(Qb(end-1:end),B(end-1:end));
%         etab_new(1,nx)      = etab(1,nx)      - MorFac * dt /cb /beta(1,nx)/(dx) * flux_bed;
end

end %function