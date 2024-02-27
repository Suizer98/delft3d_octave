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
%$Id: nodal_point_wang.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/nodal_point_wang.m $
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
%170726
%   -V & Pepijn. Created for the first time.
%
%

function bc=nodal_point_wang(qbk_bra,bc,input,nbi,nodparam,fid_log,kt)
    br_mat=input(1,1).grd.br_mat;

    ord_up=br_mat(nbi,7);                           %parent
    ord_d1=nbi;                                     %current branch
    ord_d2=br_mat(nbi,8);                           %companion branch
    
    
    Qbct = mod(kt,bc(ord_d1,1).repQT(2))+(mod(kt,bc(ord_d1,1).repQT(2))==0)*bc(ord_d1,1).repQT(2);
    Qbbct = mod(kt,bc(ord_d1,1).repQbkT(2))+(mod(kt,bc(ord_d1,1).repQbkT(2))==0)*bc(ord_d1,1).repQbkT(2);
    
    sedrat=(bc(ord_d1,1).Q0(Qbct)/bc(ord_d2,1).Q0(Qbct)).^nodparam + (input(ord_d1,1).grd.B(1)/input(ord_d2,1).grd.B(1)).^(1-nodparam);
    Qbup=[qbk_bra{ord_up,1}(:,input(ord_up,1).mdv.nx).*input(ord_up,1).grd.B(1)]';
    bc(ord_d1,1).Qbk0(Qbbct,:)=Qbup.*sedrat./(1+sedrat);
    bc(ord_d2,1).Qbk0(Qbbct,:)=Qbup-bc(ord_d1,1).Qbk0(Qbbct,:);
    
    bc(ord_d1,1).qbk0(Qbbct,:)=bc(ord_d1,1).Qbk0(Qbbct,:)./input(ord_d1,1).grd.B(1);
    bc(ord_d2,1).qbk0(Qbbct,:)=bc(ord_d2,1).Qbk0(Qbbct,:)./input(ord_d2,1).grd.B(1);
    
end
