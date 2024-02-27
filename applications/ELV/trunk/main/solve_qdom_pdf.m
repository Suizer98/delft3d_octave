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
%$Id: solve_qdom_pdf.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/solve_qdom_pdf.m $
%
function obj = solve_qdom_pdf(X, input,ib,F,AL,k)
%solve_sedigraph computes the slope and surface fraction 
% VERSION 1

%INPUT:
%   -X: dominant discharge
%   -input for parmaters
%   -ib: slope
%   -F: fraction of gravel 
%   -Qw: equidistant spaced hydrograph
%   -AL: mean annual load per fraction
%
%OUTPUT:
%   -

%HISTORY:
%
%1600901
%   L-First creation

dq = X'/input.grd.B(1,1);
h = (input.frc.Cf.*dq.^2/(9.81*ib)).^(1/3);

% Get lengths
nm = length(h);
nf = size(input.sed.dk);

% Initialize fractions
if nf>1
	Mak = 1-F; 
    La = ones(1,nm);
	if min(Mak)<0
    		warning('Negative fractions are not allowed. Revisit solver');
	end

else
	Mak = NaN*ones(size(h));
	La = NaN*ones(size(h));
end

Cf=input.frc.Cf(1).*ones(size(h));

if isfield(input,'tra.calib')==1
    [qbk,~]=sediment_transport(input.aux.flg,input.aux.cnt,h,dq,Cf,La,Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,input.tra.calib,NaN(1,2),NaN(1,2),NaN,NaN,NaN);
else
    [qbk,~]=sediment_transport(input.aux.flg,input.aux.cnt,h,dq,Cf,La',Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,NaN,NaN);
end


% Objectives:
Computed_load = qbk(k);
Annual_load = AL(k)/input.grd.B(1,1);
obj = Computed_load-Annual_load';
end

