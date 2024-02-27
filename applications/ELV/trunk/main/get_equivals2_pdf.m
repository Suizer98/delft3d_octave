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
%$Id: get_equivals2_pdf.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/get_equivals2_pdf.m $
%
%get_equivals2_pdf does this and that
%
%[B,Fk] = get_equivals2_pdf(pq,dq,input,AL,sedp,S,X0)
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
%

function [B,Fk] = get_equivals2_pdf(pq,dq,input,AL,sedp,S,X0)
ALp = AL * sedp;
input = add_sedflags(input);
F = @(X)solve_nfbc2_pdf(X,input,dq,pq,ALp,S);
options=optimoptions('fsolve','TolFun',1e-20,'TolX',1e-20,'display','none','MaxFunEvals',1000);
[X_s,~,~,~]=fsolve(F,X0,options);

disp('Sum of objective function of different transport fractions (width): (should be zero)')
sum(abs(solve_nfbc2_pdf(X_s,input,dq,pq,ALp,S)))
solve_nfbc2_pdf(X_s,input,dq,pq,ALp,S)
rel_error = solve_nfbc2_pdf(X_s,input,dq,pq,ALp,S)./ALp';

if max(abs(rel_error))>0.001;
    warning('Not sure if answer is trustworthy');
end

B = X_s(1);
Fk = X_s(2:end);
Fk = [Fk 1-sum(Fk)];

if Fk < 0
    error('Fk<0')
elseif Fk >1
    error('Fk>1')
end

end
