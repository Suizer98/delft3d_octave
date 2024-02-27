%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17760 $
%$Date: 2022-02-14 17:51:28 +0800 (Mon, 14 Feb 2022) $
%$Author: chavarri $
%$Id: mean_grain_size_gen.m 17760 2022-02-14 09:51:28Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/mean_grain_size_gen.m $
%
%Compute mean grain size 
%
%INPUT:
%
%
%OPTIONAL:
%   -type: 1=geometric (2^); 2=arithmetic (sum)
%   
%OUTPUT:
%

function Dm=mean_grain_size_gen(dk,Fak,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'type',1);

parse(parin,varargin{:});

%% CALL

input_i.tra.Dm=parin.Results.type;
input_i.sed.dk=dk;
input_i.mdv.nx=1;

Dm=mean_grain_size(Fak,input_i,NaN);

end %function