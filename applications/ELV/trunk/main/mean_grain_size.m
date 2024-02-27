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
%$Id: mean_grain_size.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/mean_grain_size.m $
%
%mean_grain_size computes the mean grain size
%
%Dm=mean_grain_size(Mak,La,input,fid_log)
%
%INPUT:
%   -Fak [nf,nx]
%
%OUTPUT:
%   -
%
%HISTORY:
%180605
%   -V. Created for the first time.
%


function Dm=mean_grain_size(Fak,input,fid_log)


%% 
%% RENAME
%% 

nx=input.mdv.nx;
dk=input.sed.dk; %[nf,1]

dk=reshape(dk,numel(dk),1);
%%
%% CALC
%%

switch input.tra.Dm
    case 1 %geometric
        Dm=2.^sum(Fak.*repmat(log2(dk),1,nx),1); %[nf,nx]
    case 2 %arithmetic
        Dm=sum(Fak.*repmat(dk,1,nx),1); %[nf,nx]
end
end %function


