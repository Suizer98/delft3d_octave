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
%$Id: get_equivals_pdf.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/get_equivals_pdf.m $
%
%get_equivals_pdf does this and that
%
%[S,Fk] = get_equivals_pdf(pq,dq,input,AL,sedp,X0)
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

function [S,Fk] = get_equivals_pdf(pq,dq,input,AL,sedp,X0)
ALp = AL * sedp;
input = add_sedflags(input);
F = @(X)solve_nfbc_pdf(X,input,dq,pq,ALp);
options=optimoptions('fsolve','TolFun',1e-16,'TolX',1e-16,'display','none','MaxFunEvals',1000);
[X_s,~,~,~]=fsolve(F,X0,options);

rel_error = solve_nfbc_pdf(X_s,input,dq,pq,ALp)./ALp';
if max(abs(rel_error))>0.001
    disp('Sum of objective function of different transport fractions: (should be zero)')
    rel_error
    warning('Not sure if answer is trustworthy');
end

S = X_s(1);
Fk = X_s(2:end);
Fk = [Fk 1-sum(Fk)];

if Fk < 0
    error('Fk<0')
elseif Fk >1
    error('Fk>1')
end

end
