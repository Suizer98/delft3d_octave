%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17936 $
%$Date: 2022-04-05 19:43:17 +0800 (Tue, 05 Apr 2022) $
%$Author: chavarri $
%$Id: D3D_mor.m 17936 2022-04-05 11:43:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_mor.m $
%
%morphological initial file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_mor(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% RENAME

D3D_structure=simdef.D3D.structure;

%% FILE

D3D_mor_su(simdef,'check_existing',check_existing);

% if D3D_structure==1
%     D3D_mor_s(simdef);
% else
%     D3D_mor_u(simdef,'check_existing',check_existing);
% end