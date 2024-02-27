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
%$Id: find_immobile_fractions.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/find_immobile_fractions.m $
%
%find indices of immobile fractions
%
%\texttt{}
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%200708
%   -V. Created for the first time.
%

function imm_idx=find_immobile_fractions(qbk,La,Mak,input,fid_log)

%% RENAME

nef=input.mdv.nef;
nx=input.mdv.nx; %number of cells

tol=1e-5;
Fak=Mak./La; %volume fractions at the active layer [-]; [nef x nx double]

%% CALC

Fak_full=NaN(nef+1,nx);
Fak_full(1:nef,:)=Fak;
Fak_full(end,:)=1-sum(Fak,1);
Fak_full(Fak_full>1+tol)=1;
Fak_full(Fak_full<tol)=0;
imm_idx=Fak_full~=0 & qbk==0; %detect immobile fractions

end %function













