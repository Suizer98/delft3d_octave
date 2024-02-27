%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18069 $
%$Date: 2022-05-21 00:31:37 +0800 (Sat, 21 May 2022) $
%$Author: chavarri $
%$Id: D3D_xml.m 18069 2022-05-20 16:31:37Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_xml.m $
%
%

function D3D_xml(fpath_xml,fname_mdu,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'check_existing',true)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% FILE

if check_existing && exist(fpath_xml,'file')==2
    error('File exists and you don''t want to overwrite %s',fpath_xml)
end

[~,~,ext]=fileparts(fname_mdu);
switch ext
    case '.mdu'
        structure=2;
    case '.mdf'
        structure=1;
    otherwise
        error('not sure what structure is file %s',fname_mdu)
end

switch structure
    case 1
        D3D_d3d4_config(fpath_xml,fname_mdu)
    case 2
        D3D_dimr_config(fpath_xml,fname_mdu);
end

