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
%$Id: bed_FTBS.m 17437 2021-08-02 03:19:02Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/bed_FTBS.m $
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
%160223
%   -V. Created for the first time.
%
%160429
%   -V. Introduction of periodic boundary conditions
%
%160623
%   -V. Cyclic boundary conditions.
%
%160803
%	-L. Merging; including cycled boundary conditions
%
%170126
%   -L. Added cases 13,14 (no new version)
%
%170516
%   -V. Erased upwind factor
%
%171005
%   -V. Added entrianment deposition formulation
%   -V. Add pmm to general update
%
%200715
%   -V. Solved bug with unsteady flow and mixed-size sediment

function etab_new=bed_FTBS(input,etab,Qb0,Qb,beta)

%%
%% RENAME
%%

dx=input.grd.dx;
dt=input.mdv.dt;    
MorFac=input.mor.MorFac;
cb=1-input.mor.porosity;
nx=input.mdv.nx; %number of cells
% nf=input.mdv.nf; 
UpwFac=input.mdv.UpwFac;
% bc_interp_type=input.mdv.bc_interp_type;
B=input.grd.B;
% beta=pmm(2,:); 

%%
%% CALC
%%

switch input.mdv.flowtype
    case {0,1,6}
        if input.bcm.type==4
            etab_new(1,1)=etab(1,1);
        else
            etab_new(1,1)      = etab(1,1)      - MorFac * dt /cb /beta(1,1     ) * ((UpwFac * ((Qb(1)     -Qb0       ) /(dx/2)) + (1-UpwFac) * ((Qb(2)   -Qb(1)     ) /(dx/2))) /B(2   ));
        end
        etab_new(1,2:nx-1) = etab(1,2:nx-1) - MorFac * dt./cb./beta(1,2:nx-1).* ((UpwFac * ((Qb(2:nx-1)-Qb(1:nx-2))./(dx  )) + (1-UpwFac) * ((Qb(3:nx)-Qb(2:nx-1))./(dx  )))./B(3:nx));
        etab_new(1,nx)     = etab(1,nx)     - MorFac * dt /cb /beta(1,nx    ) * (           (Qb(nx)    -Qb(nx-1)  ) /(dx  ))/B(end);  
    case {2,3,4}
        UpwFac = 1-(Qb<0); %sets the UpwFac to 1 if flow comes from left, and to 0 if flow comes from right [1,nx] double
        if input.bcm.type==4
            etab_new(1,1)=etab(1,1);
        else
            etab_new(1,1) = etab(1,1) - MorFac * dt./cb/beta(1,1).* ((UpwFac(1) * ((Qb(1)-Qb0)./(dx/2)) + (1-UpwFac(1)) * ((Qb(2)-Qb(1))./(dx/2)))./B(1));
        end
        %!ATTENTION! there seems to be an inconsistency between the
        %case above and this one regarding the width in the last
        %fraction. Above it is B(3:nx) and below it is B(2:end-1)
        etab_new(1,2:nx-1) = etab(1,2:nx-1) - MorFac * dt./cb./beta(1,2:nx-1).* (UpwFac(2:nx-1).* ((Qb(2:nx-1)-Qb(1:nx-2))./(dx)) + (1-UpwFac(2:nx-1)).* ((Qb(3:nx)-Qb(2:nx-1))./(dx)))./B(2:end-1);  
        if Qb(nx)>0              
            etab_new(1,nx) = etab(1,nx) - MorFac * dt/cb/beta(1,nx) * ((Qb(nx)-Qb(nx-1))/(dx))/B(end);
        else
            etab_new(1,nx) = etab(1,nx);
        end

    otherwise
        error('Supposedly you do not end up here');
end

end %function