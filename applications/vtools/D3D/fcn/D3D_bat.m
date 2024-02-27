%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18270 $
%$Date: 2022-08-01 18:23:51 +0800 (Mon, 01 Aug 2022) $
%$Author: chavarri $
%$Id: D3D_bat.m 18270 2022-08-01 10:23:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_bat.m $
%

function [strsoft_lin,strsoft_win]=D3D_bat(simdef,fpath_software,varargin)

%% 

dire_sim=simdef.D3D.dire_sim;
structure=simdef.D3D.structure;
% fname_mdu=simdef.runid.name; %runid does not have the extension!
runid=simdef.runid.name;

% [~,~,ext]=fileparts(fname_mdu);
% switch ext
%     case '.mdu'
%         structure=2;
%     case '.mdf'
%         structure=1;
%     otherwise
%         error('not sure what structure is file %s',fname_mdu)
% end

switch structure
    case 1
        ext='.mdf';
    case 2
        ext='.mdu';
    otherwise
        error('do something')
end
fname_mdu=sprintf('%s%s',runid,ext);

%% PARSE

parin=inputParser;

switch structure
    case 1 
        addOptional(parin,'dimr','config_d_hydro.xml');
    case 2
        addOptional(parin,'dimr','dimr_config.xml');
end

parse(parin,varargin{:});

dimr_str=parin.Results.dimr;

%%

if strcmp(fpath_software(end),'\') || strcmp(fpath_software(end),'/')
    fpath_software(end)='';
end

fpath_dimr=fullfile(dire_sim,dimr_str);

%% dimr

D3D_xml(fpath_dimr,fname_mdu)

%% batch

[strsoft_lin,strsoft_win]=D3D_bat_write(dire_sim,fpath_software,dimr_str,structure);

end %function