%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: S3_convert_dimr.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/S3_convert_dimr.m $
%
%Converts a dimr configuration file from SOBEK-3 format to FM format

function S3_convert_dimr(path_s3,varargin)

parin=inputParser;

[folder,~,~]=fileparts(path_s3);
def.path_fm=fullfile(folder,'dimr_config.xml');
addOptional(parin,'path_fm',def.path_fm);

parse(parin,varargin{:});

path_fm=parin.Results.path_fm;

%read sobek3
dimr_s3=read_ascii(path_s3);

%modify
dimr_fm=dimr_s3;
nl=numel(dimr_fm);

for kl=1:nl
      
    dimr_fm{kl}=strrep(dimr_fm{kl},'http://schemas.deltares.nl/dimr','http://schemas.deltares.nl/dimrConfig');
    dimr_fm{kl}=strrep(dimr_fm{kl},'http://schemas.deltares.nl/dimr http://content.oss.deltares.nl/schemas/dimr-1.2.xsd','http://schemas.deltares.nl/dimrConfig http://content.oss.deltares.nl/schemas/d_hydro-1.00.xsd');
    dimr_fm{kl}=strrep(dimr_fm{kl},'<fileVersion>1.2</fileVersion>','<fileVersion>1.0</fileVersion>');
    dimr_fm{kl}=strrep(dimr_fm{kl},'<library>cf_dll</library>','<library>dflowfm</library>');
    dimr_fm{kl}=strrep(dimr_fm{kl},'<workingDir>dflow1d</workingDir>','<workingDir>dflowfm</workingDir>');
    dimr_fm{kl}=strrep(dimr_fm{kl},'.md1d','.mdu');
    
    dimr_fm{kl}=strrep(dimr_fm{kl},'structure_crest_level','CrestLevel');
    dimr_fm{kl}=strrep(dimr_fm{kl},'structure_crest_width','CrestWidth');
    if contains(dimr_fm{kl},'structure_gate_lower_edge_level')
        dimr_fm{kl}=strrep(dimr_fm{kl},'weirs','generalstructures');
        dimr_fm{kl}=strrep(dimr_fm{kl},'structure_gate_lower_edge_level','gateLowerEdgeLevel');
    end   
    dimr_fm{kl}=strrep(dimr_fm{kl},'flow1d_to_rtc','flowfm_to_rtc');
    dimr_fm{kl}=strrep(dimr_fm{kl},'rtc_to_flow1d','rtc_to_flowfm');
    dimr_fm{kl}=strrep(dimr_fm{kl},'structure_setpoint','capacity');
    
    
end %kl

%write

writetxt(path_fm,dimr_fm,'check_existing',false)

fprintf('dimr file exported at: %s \n',path_fm)
