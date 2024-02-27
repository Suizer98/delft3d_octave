%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18082 $
%$Date: 2022-05-27 22:38:11 +0800 (Fri, 27 May 2022) $
%$Author: chavarri $
%$Id: cell2mat_clean.m 18082 2022-05-27 14:38:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/cell2mat_clean.m $
%
%

function [m,idx]=cell2mat_clean(c)

idx=[];
for k1=1:size(c,1)
    for k2=1:size(c,2)
        if ~isnumeric(c{k1,k2})
            idx=cat(1,idx,[k1,k2]);
            c{k1,k2}=NaN;
        end
    end
end

m=cell2mat(c);


