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
%$Id: solve_Hdown.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/solve_Hdown.m $
%
function obj = solve_Hdown(X,input,dQ,pQ,AL)
%solve_Hdown computes H_down
% VERSION 3

%INPUT:
%   -input
%
%OUTPUT:
%   -

%HISTORY:
%
%1600825
%   -L. Updated to use only 100 modes
%       Made header
%160829
%   -L. Updated for mixed sediments
nm = length(dQ);
nf = input.mdv.nf;

switch input.mdv.nf
    
    case 1        
        h = X*ones(size(dQ));
        Cf=input.frc.Cf.*ones(size(h));              
        La=NaN * ones(size(h));
        Mak=NaN * ones(size(h));
        [qbk,~]=sediment_transport(input.aux.flg,input.aux.cnt,h,dQ,Cf,La,Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,NaN,NaN);
        obj = sum(qbk.*pQ)-AL;
    
    otherwise
        X
        h = X(1)*ones(size(dQ));
        %Mak = zeros(nf,nm);
        %Mak(2:end,:) = repmat(X(2:end),1,nm);
        %Mak(1,:) = ones(1,nm) - sum(Mak(2:end,:),1);
        Mak = repmat(X(2:end),1,nm);
        Cf=input.frc.Cf.*ones(size(h));  
        if min(Mak)<0
            error('Negative fractions are not allowed. Revisit solver');
        end
        La = ones(1,nm);
        [qbk,~]=sediment_transport(input.aux.flg,input.aux.cnt,h,dQ,Cf,La,Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,NaN,NaN);
              
        % Objectives:
        % - Total mass per fraction is transported
        % - Sum of all fractions is one. 
        Computed_load = sum(qbk.*repmat(pQ,1,nf))
        Annual_load = AL
        obj = Computed_load-Annual_load;       
end
end

