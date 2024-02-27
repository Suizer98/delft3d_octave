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
%$Id: flow_update_branches.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/flow_update_branches.m $
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

function [u,h,Q,etaw0]=flow_update_branches(u,h,Q,etaw0,etab,Cf,bc,Qbct,hbct,input,kb,fid_log)
    
    %easy variables
    br_mat=input(1,1).grd.br_mat;
    br_ord=input(1,1).grd.br_ord;
    nx    =input(br_ord(kb,1),1).mdv.nx;
    
    if br_mat(br_ord(kb,1),3)>0
        %
        % Upstream boundary
        %
        
        %easy variables
        ord_d=input(1,1).grd.br_ord(kb,1);
        
        %update discharge
        Q(ord_d,1)=bc(ord_d,1).Q0(Qbct,1);
        
        %retrieve downstream water depth, or BC other branches
        if kb~=numel(br_ord)
            [u,h,Q,etaw0]=flow_update_branches(u,h,Q,etaw0,etab,Cf,bc,Qbct,hbct,input,kb+1,fid_log);
        end
        
        if br_mat(ord_d,4)>0
            etaw0(ord_d,1)=bc(ord_d,1).etaw0(hbct,1);
        end
        
        H0=etaw0(ord_d,1)-3/2*etab{ord_d,1}(1,nx)+1/2*etab{ord_d,1}(1,nx-1);
                
        % do backwater in this branch
        [u{ord_d,1},h{ord_d,1}]=flow_update_backwatersolver(Q(ord_d,1)/input(ord_d,1).grd.B(1),H0,Cf{ord_d},etab{ord_d},input(ord_d),fid_log);
    
    elseif br_mat(br_ord(kb,1),6)==1
        %
        % Bifurcation
        %
        
        [u,h,Q,etaw0]=bifurcation_solver(u,h,Q,etaw0,etab,Cf,bc,Qbct,hbct,input,kb,fid_log);

    elseif br_mat(br_ord(kb,1),6)==0
        %
        % Confluence
        %
              
        %easy variables
        ord_do=input(1,1).grd.br_ord(kb,1);             % current branch
        ord_u1=br_mat(input(1,1).grd.br_ord(kb,1),7);   %Upstream friend 1
        ord_u2=br_mat(input(1,1).grd.br_ord(kb,1),8);   %Upstream friend 2
        
        Q(ord_do,1)=sum(Q([ord_u1 ord_u2]',1));
        
        % request downstream water level boundary
        if kb~=numel(br_ord)
            [u,h,Q,etaw0]=flow_update_branches(u,h,Q,etaw0,etab,Cf,bc,Qbct,hbct,input,kb+1,fid_log);
        end
       
        if br_mat(ord_do,4)>0
            etaw0(ord_do,1)=bc(ord_do,1).etaw0(hbct,1);
        end
        
        % set and compute h0 for downstream branch
        H0=etaw0(ord_do,1)-3/2*etab{ord_do}(1,nx)+1/2*etab{ord_do}(1,nx-1);
        
        % update water depth and flow velocity in this branch
        [u{ord_do},h{ord_do}]=flow_update_backwatersolver(Q(ord_do,1)/input(ord_do,1).grd.B(1),H0,Cf{ord_do},etab{ord_do},input(ord_do),fid_log);
        
        % Update water level boundary for upstream branches
        etaw0(ord_u1,1)=h{ord_do}(1,1)+3/2*etab{ord_do}(1,1)-1/2*etab{ord_do}(1,2);
        etaw0(ord_u2,1)=etaw0(ord_u1,1);
        
    else
        error('Node is not a boundary, not a bifurcation, and not a confluence. Please explain...') 
    end

    
end