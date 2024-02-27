%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17637 $
%$Date: 2021-12-09 05:21:26 +0800 (Thu, 09 Dec 2021) $
%$Author: chavarri $
%$Id: parse_layout.m 17637 2021-12-08 21:21:26Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/parse_layout.m $
%

%function out=f(varargin)

parin=inputParser;

addOptional(parin,'sedTrans',0,@isnumeric);

parse(parin,varargin{:});

sedTrans=parin.Results.sedTrans;

%%

OPT.ask=1;
OPT=setproperty(OPT,varargin);