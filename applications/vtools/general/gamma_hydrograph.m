%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17700 $
%$Date: 2022-02-01 16:11:39 +0800 (Tue, 01 Feb 2022) $
%$Author: chavarri $
%$Id: gamma_hydrograph.m 17700 2022-02-01 08:11:39Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/gamma_hydrograph.m $
%
%Gamma function hydrograph from USDA07 (National engineering handbook hydrology, chapter 16, hydrographs. United States Department of Agriculture, Natural Resources Conservation Service.)

function [q,qint]=gamma_hydrograph(q_b,q_p,m,t,t_p)

q=q_b+(q_p-q_b).*exp(m).*(t./t_p).^m.*exp(-m.*t./t_p);
qint=trapz(t,q);

end %function
