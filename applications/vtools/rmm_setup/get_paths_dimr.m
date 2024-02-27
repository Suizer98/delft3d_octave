%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: get_paths_dimr.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/rmm_setup/get_paths_dimr.m $
%

function paths=get_paths_dimr(paths)

%% READ DIMR

xml_in=read_ascii(paths.dimr_in);

%rtc folder
kl=search4lineinascii(xml_in,'FBCTools_BMI','</dimrConfig>');
tok=regexp(xml_in{kl+1,1},'<workingDir>(\w+)</workingDir>','tokens');
if isempty(tok)
   error('cannot find RTC folder in DIMR file') 
else
    rtc_folder=tok{1,1}{1,1};
end

kl=search4lineinascii(xml_in,'cf_dll','</dimrConfig>');
tok=regexp(xml_in{kl+1,1},'<workingDir>(\w+)</workingDir>','tokens');
if isempty(tok)
   error('cannot find dflow1d folder in DIMR file') 
else
    dflow1d_folder=tok{1,1}{1,1};
end


%% paths s3

[path_s3,path_dimr_in,path_dimr_in_ext]=fileparts(paths.dimr_in);
simdef.D3D.dire_sim=fullfile(path_s3,dflow1d_folder);
simdef.D3D.structure=3;
simdef=D3D_simpath(simdef);
path_xml_rtcRuntimeConfig=fullfile(paths.s3_out,rtc_folder,'rtcRuntimeConfig.xml');
path_xml_rtctimeseries=fullfile(paths.s3_out,rtc_folder,'timeseries_import.xml');
path_dimr=fullfile(paths.s3_out,sprintf('%s%s',path_dimr_in,path_dimr_in_ext));

[~,md1d_filename,md1d_ext]=fileparts(simdef.file.mdf);
path_md1d=fullfile(paths.s3_out,dflow1d_folder,sprintf('%s%s',md1d_filename,md1d_ext));

[~,bc_filename,bc_ext]=fileparts(simdef.file.bc);
path_bc=fullfile(paths.s3_out,dflow1d_folder,sprintf('%s%s',bc_filename,bc_ext));

%% out

paths.xml_rtcRuntimeConfig=path_xml_rtcRuntimeConfig;
paths.xml_rtctimeseries=path_xml_rtctimeseries;
paths.md1d=path_md1d;
paths.bc=path_bc;
paths.s3=path_s3;
paths.dimr=path_dimr;

end %function