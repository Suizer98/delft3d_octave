%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: regexp_layout.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/regexp_layout.m $
%
%writes reference in tex file

%     id                    = #0001#
expr='\w+([.-]?\w+)*';
str_aux_r=regexp(str_aux,expr,'match');

%%

tok=regexp(grainp{kl,1},'\$GSLEVUNLA Branch\s+(\d+)\s+AT\s+(\d+)\s+(-?\d+.\d+)','tokens');

%maybe decimal, maybe not
tok=regexp(t2,'([+-]?(\d+(\.\d+)?)|(\.\d+))','tokens')
