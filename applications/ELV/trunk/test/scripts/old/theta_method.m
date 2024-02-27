%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16592 $
%$Date: 2020-09-17 01:32:43 +0800 (Thu, 17 Sep 2020) $
%$Author: chavarri $
%$Id: theta_method.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/test/scripts/old/theta_method.m $
%
%active_layer_mass_update updates the mass (volume) of sediment at the active layer.
%
%\texttt{Mak_new=active_layer_mass_update(Mak,detaLa,fIk,qbk,bc,input,fid_log,kt)}
%
%INPUT:
%   -\texttt{Mak} = effective volume of sediment per unit of bed area in the active layer [m]; [(nf-1)x(nx) double]
%   -\texttt{detaLa} = variation in elevation of the interface between the active layer and the substarte [m]; [(1)x(nx) double]
%   -\texttt{fIk} = effective volume fraction content of sediment at the interface between the active layer and the substrate [-]; [(nf-1)x(nx) double]
%   -\texttt{qbk} = volume of sediment transported excluding pores per unit time and width and per size fraction [m^2/s]; [(nf)x(nx) double]
%   -\texttt{bc} = boundary conditions structure 
%   -\texttt{input} = input structure
%   -\texttt{fid_log} = identificator of the log file
%   -\texttt{kt} = time step counter [-]; [(1)x(1) double]
%
%OUTPUT:
%   -\texttt{Mak_new} = new effective volume of sediment per unit of bed area in the active layer [m]; [(nf-1)x(nx) double]
%
%HISTORY:
%171002
%   -V. Created it for the first time

function C_new=theta_method(C_old,alpha,beta,gamma,delta,input,fid_log)

%%
%% RENAME
%%

nx=input.mdv.nx; 
theta=input.mdv.theta;

%%
%% BOUNDARY CONDITION
%%

% switch input.bcm.theta_method
%     case 1 %fixed value upstream and downstream
%         C1=C_old(1);
%         C1=C_old(1);
%     case 2
%          
%     otherwise
%         error('Thanks for using ELV! It is awesome eh? but you better provide a input.bcm.type that makes sense...')
% end

%%
%% FILL MATRIX
%%
R=C_old(2:end-1)-alpha(2:end-1).*(1-theta).*(C_old(3:end)-C_old(1:end-2))+beta(2:end-1).*(1-theta).*(C_old(3:end)-2.*C_old(2:end-1)+C_old(1:end-2))+gamma(2:end-1)+delta(2:end-1).*(1-theta).*C_old(2:end-1);
%matrix with the tridiagonals
D=[[-theta*(alpha(3:end-1)+beta(3:end-1))';0],1+2.*beta(2:end-1)'.*theta-delta(2:end-1)'.*theta,[0;theta.*(alpha(2:end-2)'-beta(2:end-2)')]];
%system matrix
A=spdiags(D,[-1,0,1],nx-2,nx-2);
%source
B=R';
B(1)=B(1)+theta*(alpha(2)+beta(2))*C_old(1);
B(end)=B(end)-theta*(alpha(end-1)-beta(end-1))*C_old(end);
%solve
C=mldivide(A,B);
%add bc
C_new=[C_old(1);C;C_old(end)]';







