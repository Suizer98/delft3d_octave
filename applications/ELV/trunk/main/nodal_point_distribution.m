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
%$Id: nodal_point_distribution.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/nodal_point_distribution.m $
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

function bc=nodal_point_distribution(u_bra,h_bra,etab_bra,qbk_bra,thetak_bra,Cf_bra,bc,input,fid_log,kt)
    nb=input(1,1).mdv.nb;
    if nb>1
        br_mat=input(1,1).grd.br_mat;
        %% bifurcations
        switch input(1,1).mor.nodal
            case 1 % Wang
                for nbi=(input(1,1).grd.nbif)'
                    if size(input(1,1).mor.nodparam,1)>1
                        bc=nodal_point_wang(qbk_bra,bc,input,nbi,input(1,1).mor.nodparam(br_mat(nbi,1),:),fid_log,kt);
                    else
                        bc=nodal_point_wang(qbk_bra,bc,input,nbi,input(1,1).mor.nodparam,fid_log,kt);
                    end
                end
            case 2 % Bolla Pitaluga
                for nbi=(input(1,1).grd.nbif)'
                    if size(input(1,1).mor.nodparam,1)>1
                        bc=nodal_point_bolla(u_bra,h_bra,etab_bra,qbk_bra,thetak_bra,Cf_bra,bc,input,nbi,input(1,1).mor.nodparam(br_mat(nbi,1),:),fid_log,kt);
                    else
                        bc=nodal_point_bolla(u_bra,h_bra,etab_bra,qbk_bra,thetak_bra,Cf_bra,bc,input,nbi,input(1,1).mor.nodparam,fid_log,kt);
                    end
                end
            otherwise
                error('This nodal point relation is unknown')

        end
        
        %% confluences
        Qbbct = mod(kt,bc(1,1).repQbkT(2))+(mod(kt,bc(1,1).repQbkT(2))==0)*bc(1,1).repQbkT(2);
        
        log_conf=logical(br_mat(:,6)~=1 .* br_mat(:,3)==0);
        loc_conf=[1:nb]';
        for nk=[loc_conf(log_conf,1)]'
            ord_do =nk;
            ord_up1=br_mat(ord_do,7);                           %parent 1
            ord_up2=br_mat(ord_do,8);                           %parent 2

            bc(ord_do,1).Qbk0(Qbbct,:)=qbk_bra{ord_up1,1}(:,input(ord_up1,1).mdv.nx).*input(ord_up1,1).grd.B(1) +...
                                       qbk_bra{ord_up2,1}(:,input(ord_up2,1).mdv.nx).*input(ord_up2,1).grd.B(1);
            bc(ord_do,1).qbk0(Qbbct,:)=bc(ord_do,1).Qbk0(Qbbct,:)./input(ord_do,1).grd.B(1);
        end
    end
end













