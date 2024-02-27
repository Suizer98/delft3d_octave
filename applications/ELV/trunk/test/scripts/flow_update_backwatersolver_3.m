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
%$Id: flow_update_backwatersolver_3.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/test/scripts/flow_update_backwatersolver_3.m $
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

function [U,H]=flow_update_backwatersolver_3(qwup,Hdown,Cf,etab,input,fid_log,kt)

    %Fully based on the standard steady state solver 
    g =input.mdv.g;
    nx=input.mdv.nx;
    dx=input.grd.dx;
    B =input.grd.B;
    flowtype=input.mdv.flowtype;
    
    %downstream condition
    H(1,nx)=Hdown;
    qw=(qwup*B(1)./B);
    Energy(1,nx)=etab(1,nx)+Hdown+0.5*qw(1,nx)^2/(g*Hdown^2);
    for kx=nx-1:-1:1      
        R1=dx*Sf_fun(H(kx+1)     ,qw(kx+1),Cf(kx+1),g);
        if flowtype==7 %RK4
            R2=dx*Sf_fun(H(kx+1)+R1/2,qw(kx+1),Cf(kx+1),g);
            R3=dx*Sf_fun(H(kx+1)+R2/2,qw(kx+1),Cf(kx+1),g);
            R4=dx*Sf_fun(H(kx+1)+R3  ,qw(kx+1),Cf(kx+1),g);

            Energy(1,kx)=Energy(1,kx+1)+1/6*(R1+2*R2+2*R3+R4);
        else %Euler
            Energy(1,kx)=Energy(1,kx+1)+R1;
        end
        %  Invert the energy function analytically
        acoeff=1;
        bcoeff=-(Energy(1,kx)-etab(1,kx));
        ccoeff=0;
        dcoeff=0.5*qw(1,kx)^2/g;
        root=analytical_cubic_root(acoeff,bcoeff,ccoeff,dcoeff);
        H(1,kx)=max(root); %Select the subcritical value
%         Sf(1,kx)=Cf(1,kx)*(qw(1,kx)/(H(1,kx)))^2*(1/(g*H(1,kx))); %((1/sqrt(Cf_q(j,1)))*H(j,1)/qw(j,1)).^(-2)*1/(g*H(j,1)); 
    end
    U=qw./H; %[1x(nx) double]
end

function Sf_v=Sf_fun(H_v,qw_v,Cf_v,g)

    Sf_v=Cf_v*(qw_v/(H_v))^2*(1/(g*H_v));
    
end