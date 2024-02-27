%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17948 $
%$Date: 2022-04-08 21:56:21 +0800 (Fri, 08 Apr 2022) $
%$Author: chavarri $
%$Id: now_chr.m 17948 2022-04-08 13:56:21Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/now_chr.m $
%
%String of now

function nowchr=now_chr(varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'random',0)
% addOptional(parin,'long',0)

parse(parin,varargin{:})

radd=parin.Results.random;
% lstr=parin.Results.long;

if radd
    rng('shuffle')
    r=rand(1);
else 
    r=0;
end

nw=sprintf('%15.10f',datenum(datetime('now'))+r);
nowchr=strrep(nw,'.','_');

end %function