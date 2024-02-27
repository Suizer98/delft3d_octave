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
%$Id: nodal_point_bolla.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/nodal_point_bolla.m $
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

function bc=nodal_point_bolla(u_bra,h_bra,etab_bra,qbk_bra,thetak_bra,Cf_bra,bc,input,nbi,nodparam,fid_log,kt)
    br_mat=input(1,1).grd.br_mat;
    alpha=nodparam(1,1);
    r=nodparam(1,2);

    ord_up=br_mat(nbi,7);                           %parent
    ord_d1=nbi;                                     %current branch
    ord_d2=br_mat(nbi,8);                           %companion branch
    Qbct = mod(kt,bc(ord_d1,1).repQT(2))+(mod(kt,bc(ord_d1,1).repQT(2))==0)*bc(ord_d1,1).repQT(2);
    Qbbct = mod(kt,bc(ord_d1,1).repQbkT(2))+(mod(kt,bc(ord_d1,1).repQbkT(2))==0)*bc(ord_d1,1).repQbkT(2);
    
    
    Qy=0.5*(bc(ord_d1,1).Q0(Qbct,1)-bc(ord_d2,1).Q0(Qbct,1)-bc(ord_up,1).Q0(Qbct,1)*(input(ord_d1,1).grd.B(1)-input(ord_d2,1).grd.B(1))/(input(ord_d1,1).grd.B(1)+input(ord_d2,1).grd.B(1)));
    habc=0.5*((h_bra{ord_d1}(1,1)+h_bra{ord_d2}(1,1))/2+h_bra{ord_up}(1,input(ord_up,1).mdv.nx));
    detady=(etab_bra{ord_d1}(1,1)-etab_bra{ord_d2}(1,1))./(input(ord_up,1).grd.B(1)/2);
    
    qsy=qbk_bra{ord_up,1}(:,input(ord_up,1).mdv.nx).*((Qy*h_bra{ord_up,1}(1,input(ord_up,1).mdv.nx))/(bc(ord_up,1).Q0(Qbct,1)*alpha*habc)-detady.*r./sqrt(thetak_bra{ord_up,1}(input(ord_up,1).mdv.nx,:)));
    Qsy=qsy*alpha*input(ord_up,1).grd.B(1);
    
    Qbup=[qbk_bra{ord_up,1}(:,input(ord_up,1).mdv.nx).*input(ord_up,1).grd.B(1)]';
    Qs_d1=Qsy+(input(ord_d1,1).grd.B(1)/(input(ord_d1,1).grd.B(1)+input(ord_d2,1).grd.B(1))*Qbup);
    if Qs_d1<0
        bc(ord_d1,1).Qbk0(Qbbct,:)=max([-1*Qbup;Qs_d1],[],1);
    else
        bc(ord_d1,1).Qbk0(Qbbct,:)=min([Qbup;Qs_d1],[],1);
    end
    bc(ord_d2,1).Qbk0(Qbbct,:)=Qbup-bc(ord_d1,1).Qbk0(Qbbct,:);
    
    bc(ord_d1,1).qbk0(Qbbct,:)=bc(ord_d1,1).Qbk0(Qbbct,:)/input(ord_d1,1).grd.B(1);
    bc(ord_d2,1).qbk0(Qbbct,:)=bc(ord_d2,1).Qbk0(Qbbct,:)/input(ord_d2,1).grd.B(1);
end
