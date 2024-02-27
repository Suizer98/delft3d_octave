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
%$Id: get_sedigraph.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/get_sedigraph.m $
%
%get_sedigraph does this and that
%
%Qb = get_sedigraph(Qw,input,S,Fk)
%
%INPUT:
%   -input = input structure
%
%OUTPUT:
%   -
%
%HISTORY:
%161128
%   -L. Created for the first time

function Qb = get_sedigraph(Qw,input,S,Fk)
% S is equilibrium slope
% Fk is all the fractions; we select all but the coarsest which is
% 1-sum(others)
input = add_sedflags(input);
if numel(input.sed.dk)>1
    La = ones(1,numel(Qw));
    Mak = repmat(Fk(1:end-1)',1,numel(Qw));
else
    La = NaN*ones(1,numel(Qw));
    Mak = NaN*ones(1,numel(Qw));
end    
h = (input.frc.Cf(1).*(Qw/input.grd.B(1,1)).^2/(9.81*S)).^(1/3);
Cf = input.frc.Cf(1).*ones(1,numel(Qw)); 
if isfield(input,'tra.calib')==1
else 
    input.tra.calib =1;
end
[qbk,~]=sediment_transport(input.aux.flg,input.aux.cnt,h,Qw/input.grd.B(1,1),Cf,La,Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,input.tra.calib,NaN(1,2),NaN(1,2),NaN,NaN,NaN);
Qb = qbk*input.grd.B(1,1);
end
