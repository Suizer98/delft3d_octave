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
%$Id: flow_update_branches_tmp.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/flow_update_branches_tmp.m $
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

function [u,h,Q]=flow_update_branches(u,h,Q,etab,Cf,bc,Qbct,hbct,input,kb,fid_log,kt)
    
    %easy variables
    nx    =input(input(1,1).grd.br_ord(kb,1),1).mdv.nx;
    
    if input(1,1).grd.br_mat(input(1,1).grd.br_ord(kb,1),3)>0
        %
        % Upstream boundary
        %
        
        %easy variables
        ord_d=input(1,1).grd.br_ord(kb,1);
        
        %update discharge
        Q(ord_d,1)=bc(ord_d,1).Q0(1,Qbct);
        
        % Update branches with higher flow order first if existing
        if kb~=numel(input(1,1).grd.br_ord)
            [u,h,Q]=flow_update_branches(u,h,Q,etab,Cf,bc,Qbct,hbct,input,kb+1,fid_log,kt);
        end

        % do backwater in this branch
        H0=bc(ord_d,1).etaw0(hbct)-3/2*etab{ord_d,1}(1,nx)+1/2*etab{ord_d,1}(1,nx-1);
        [u{ord_d,1},h{ord_d,1}]=flow_update_backwatersolver(Q(ord_d,1)/input(ord_d,1).grd.B(1),H0,Cf{ord_d},etab{ord_d},input(ord_d),fid_log,kt);
    
    elseif input(1,1).grd.br_mat(input(1,1).grd.br_ord(kb,1),6)==1
        %
        % Bifurcation
        %
        
        %easy variables
        ord_up=input(1,1).grd.br_mat(input(1,1).grd.br_ord(kb,1),7);   %parent
        ord_d1=input(1,1).grd.br_ord(kb,1);             %current branch
        ord_d2=input(1,1).grd.br_ord(kb+1,1);           %companion branch
        
        %base discharge partitioning on the previous computation
        ii=max([Qbct-1 1]); % if there is not a previous computation, use initial condition
        Q_frac= (bc(ord_d1,1).Q0(1,ii))/(bc(ord_d1,1).Q0(1,ii)+ bc(ord_d2,1).Q0(1,ii));
        
        % update discharge with new upstream discharge
        Q(ord_d1,1)=   Q_frac *Q(ord_up);
        Q(ord_d2,1)=(1-Q_frac)*Q(ord_up);
        
        deta=1E10;
        Qdiff=[.001 .999];     %fraction of the total discharge which is conveyed by branch br_ord(kb,1)
        while abs(deta)>1E-5||diff(Qdiff)>1E-4           
            
            % Update branches with higher flow order first if existing
            if  (kb+1)~=numel(input(1,1).grd.br_ord)
                [u,h,Q]=flow_update_branches(u,h,Q,etab,Cf,bc,Qbct,hbct,input,kb+2,fid_log,kt);
            end
            
            % set and compute h0 for both branches
            H01=bc(ord_d1,1).etaw0(hbct)-3/2*etab{ord_d1}(1,nx)                    +1/2*etab{ord_d1}(1,nx-1);
            H02=bc(ord_d2,1).etaw0(hbct)-3/2*etab{ord_d2}(1,input(ord_d2,1).mdv.nx)+1/2*etab{ord_d2}(1,input(ord_d2,1).mdv.nx-1);
            
            % Update water level for both downstream branches
            [u{ord_d1},h{ord_d1}]=flow_update_backwatersolver(Q(ord_d1,1)/input(ord_d1,1).grd.B(1),H01,Cf{ord_d1},etab{ord_d1},input(ord_d1),fid_log,kt);
            [u{ord_d2},h{ord_d2}]=flow_update_backwatersolver(Q(ord_d2,1)/input(ord_d2,1).grd.B(1),H02,Cf{ord_d2},etab{ord_d2},input(ord_d2),fid_log,kt);
            
            % water level difference including the effect of the water level that is not defined at the cell boundary but in the cell center
            deta=(h{ord_d1}(1,1)+3/2*etab{ord_d1}(1,1)-1/2*etab{ord_d1}(1,2)) - ...
                 (h{ord_d2}(1,1)+3/2*etab{ord_d2}(1,1)-1/2*etab{ord_d2}(1,2));          
             
            % make a new estimate of the water discharge partitioning
            if deta>0
                Qdiff(2)=Q(ord_d1,1)/Q(ord_up,1);
            else
                Qdiff(1)=Q(ord_d1,1)/Q(ord_up,1);
            end
            if diff(Qdiff)>1E-4
                Qtmp=mean(Qdiff);
                Q(ord_d1,1)=   Qtmp *Q(ord_up);
                Q(ord_d2,1)=(1-Qtmp)*Q(ord_up);
            end
        end
        
        %assign boundary conditions to upstem branch
        bc(ord_up,1).etaw0(hbct)=(h{ord_d1}(1,1)+3/2*etab{ord_d1}(1,1)-1/2*etab{ord_d1}(1,2));
        
        % Update discharge boundary current branches
        bc(ord_d1,1).Q0(1,Qbct)=Q(ord_d1,1);
        bc(ord_d2,1).Q0(1,Qbct)=Q(ord_d2,1);
        bc(ord_d1,1).q0(1,Qbct)=Q(ord_d1,1)/input(ord_d1,1).grd.B(1);
        bc(ord_d2,1).q0(1,Qbct)=Q(ord_d2,1)/input(ord_d2,1).grd.B(1);
    elseif input(1,1).grd.br_mat(input(1,1).grd.br_ord(kb,1),6)==0
        %
        % Confluence
        %
              
        %easy variables
        ord_do=input(1,1).grd.br_ord(kb,1);             % current branch
        ord_u1=input(1,1).grd.br_mat(input(1,1).grd.br_ord(kb,1),7);   %Upstream friend 1
        ord_u2=input(1,1).grd.br_mat(input(1,1).grd.br_ord(kb,1),8);   %Upstream friend 2
        
        Q(ord_do,1)=sum(Q([ord_u1 ord_u2]',1));
        
        % Update branches with higher flow order first if existing
        if kb~=numel(input(1,1).grd.br_ord)
            [u,h,Q]=flow_update_branches(u,h,Q,etab,Cf,bc,Qbct,hbct,input,kb+1,fid_log,kt);
        end
       
        % set and compute h0 for downstream branch
        H0=bc(ord_do,1).etaw0(hbct)-3/2*etab{ord_do}(1,nx)+1/2*etab{ord_do}(1,nx-1);
        
        % update water depth and flow velocity in this branch
        [u{ord_do},h{ord_do}]=flow_update_backwatersolver(Q(ord_do,1)/input(ord_do,1).grd.B(1),H0,Cf{ord_do},etab{ord_do},input(ord_do),fid_log,kt);
        
        % Update water level boundary for upstream branches
        bc(ord_u1,1).etaw0(hbct)=h{ord_do}(1,1)+3/2*etab{ord_do}(1,1)-1/2*etab{ord_do}(1,2);
        bc(ord_u2,1).etaw0(hbct)=bc(ord_u1,1).etaw0(hbct);
        
        % Update discharge boundary current branch
        bc(ord_do,1).Q0(1,Qbct)=Q(ord_do,1);
        bc(ord_do,1).q0(1,Qbct)=Q(ord_do,1)/input(ord_do,1).grd.B(1);
    else
        error('Node is not a boundary, not a bifurcation, and not a confluence. Please explain...') 
    end

    
end