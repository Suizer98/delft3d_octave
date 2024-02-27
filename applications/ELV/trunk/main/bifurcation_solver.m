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
%$Id: bifurcation_solver.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/bifurcation_solver.m $
%
%check_input is a function that checks that the input is enough and makes sense
%
%input_out=check_input(input,path_file_input,fid_log)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -input = variable containing the input [struct] e.g. input
%
%HISTORY:
%170720
%   -V & Pepijn. Created for the first time.
%
%

function [u,h,Q,etaw0]=bifurcation_solver(u,h,Q,etaw0,etab,Cf,bc,Qbct,hbct,input,kb,fid_log)

%easy variables
br_mat=input(1,1).grd.br_mat;
br_ord=input(1,1).grd.br_ord;
nx    =input(br_ord(kb,1),1).mdv.nx;

ord_up=br_mat(input(1,1).grd.br_ord(kb,1),7);   %parent
ord_d1=input(1,1).grd.br_ord(kb,1);             %current branch
ord_d2=input(1,1).grd.br_ord(kb+1,1);           %companion branch

%base discharge division on the previous computation
if any(Q([ord_d1,ord_d2])==0)
    ii=max([Qbct-1 1]);
    Q_frac0= (bc(ord_d1,1).Q0(ii,1))/(bc(ord_d1,1).Q0(ii,1)+ bc(ord_d2,1).Q0(ii,1));
else
    Q_frac0= Q(ord_d1,1)/(Q(ord_d1,1) + Q(ord_d2,1));
end

tstmat=br_mat([ord_d1; ord_d2],4)>0;
if any(tstmat)
    if tstmat(1)
        etaw0(ord_d1,1)=bc(ord_d1,1).etaw0(hbct,1);
    end
    if tstmat(2)
        etaw0(ord_d2,1)=bc(ord_d2,1).etaw0(hbct,1);
    end
end

F=@(X)aux_bifurcation_solver(X,u,h,Q,etaw0,etab,Cf,bc,Qbct,hbct,input,kb,fid_log);

% options=optimoptions('fsolve','TolFun',1e-16,'TolX',1e-16,'display','none','MaxFunEvals',1000);
% [Q_frac,~,~,~]=fsolve(F,Q_frac0,options);
options=optimset('TolX',1e-16,'display','none');
[Q_frac,~,~,~]=fzero(F,Q_frac0,options);

Q(ord_d1,1)=   Q_frac *Q(ord_up);
Q(ord_d2,1)=(1-Q_frac)*Q(ord_up);

% request downstream water level boundary
if  (kb+1)~=numel(br_ord)
    [u,h,Q,etaw0]=flow_update_branches(u,h,Q,etaw0,etab,Cf,bc,Qbct,hbct,input,kb+2,fid_log);
end

% set and compute h0 for both branches
H01=etaw0(ord_d1,1)-3/2*etab{ord_d1}(1,nx)                    +1/2*etab{ord_d1}(1,nx-1);
H02=etaw0(ord_d2,1)-3/2*etab{ord_d2}(1,input(ord_d2,1).mdv.nx)+1/2*etab{ord_d2}(1,input(ord_d2,1).mdv.nx-1);

% Update water level for both downstream branches
[u{ord_d1},h{ord_d1}]=flow_update_backwatersolver(Q(ord_d1,1)/input(ord_d1,1).grd.B(1),H01,Cf{ord_d1},etab{ord_d1},input(ord_d1),fid_log);
[u{ord_d2},h{ord_d2}]=flow_update_backwatersolver(Q(ord_d2,1)/input(ord_d2,1).grd.B(1),H02,Cf{ord_d2},etab{ord_d2},input(ord_d2),fid_log);

%assign boundary conditions
etaw0(ord_up,1)=(h{ord_d1}(1,1)+3/2*etab{ord_d1}(1,1)-1/2*etab{ord_d1}(1,2));
