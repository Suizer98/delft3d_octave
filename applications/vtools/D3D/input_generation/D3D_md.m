%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17699 $
%$Date: 2022-02-01 16:11:11 +0800 (Tue, 01 Feb 2022) $
%$Author: chavarri $
%$Id: D3D_md.m 17699 2022-02-01 08:11:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_md.m $
%
%bcm file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_md(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% RENAME

D3D_structure=simdef.D3D.structure;

%% FILE

if D3D_structure==1
    D3D_mdf(simdef,'check_existing',check_existing);
else
    D3D_mdu(simdef,'check_existing',check_existing);
end
