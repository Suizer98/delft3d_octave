%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17724 $
%$Date: 2022-02-03 13:41:30 +0800 (Thu, 03 Feb 2022) $
%$Author: chavarri $
%$Id: function_layout.m 17724 2022-02-03 05:41:30Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/function_layout.m $
%
%This does A and B
%
%INPUT:
%
%OUTPUT:
%

function 

%% PARSE

parin=inputParser;

addOptional(parin,'sedTrans',0,@isnumeric);

parse(parin,varargin{:});

sedTrans=parin.Results.sedTrans;

end %function