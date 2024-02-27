%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_bat_u.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_bat_u.m $
%
%bat file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_bat_u(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;
home=simdef.D3D.home;
switch simdef.D3D.arch
    case 1
        arch_s='win32'; 
    case 2
        arch_s='x64'; 
end

runid_serie=simdef.runid.serie;
runid_number=simdef.runid.number;

%% FILE
switch simdef.D3D.compile
    case 0
        %% problems with z-layer
% % path_exe=fullfile(home,arch_s,'dflowfm\bin\dflowfm-cli.exe');
% path_scripts=fullfile(home,arch_s,'dflowfm','scripts');
% mdu_name=sprintf('sim_%s%s.mdu',runid_serie,runid_number);
% kl=1;
% data{kl,1}='@ echo off'; kl=kl+1;
% data{kl,1}=sprintf('set scriptdir=%s',path_scripts); kl=kl+1;
% data{kl,1}='set dflowfmexedir=%scriptdir%\..\bin'; kl=kl+1;
% data{kl,1}='set "libdir=%scriptdir%\..\..\share\bin"'; kl=kl+1;
% data{kl,1}='set procdefbloomspedir=%scriptdir%\..\default'; kl=kl+1;
% data{kl,1}='set path=%dflowfmexedir%;%libdir%;%path%'; kl=kl+1;
% data{kl,1}=sprintf('"%%dflowfmexedir%%\\dflowfm-cli.exe" --autostartstop -t 1 %s',mdu_name); kl=kl+1;
% % data{kl,1}=sprintf('%s --autostartstop -t 1 %s',path_exe,mdu_name);                   kl=kl+1;
% data{kl,1}=':end';        
        %% better D3D4?
% path_bat=fullfile(home,arch_s,'dflowfm','scripts','run_dflowfm.bat'); %c:\Users\chavarri\checkouts\oss_artifacts_x64_64757\x64\dflow2d3d\scripts\run_dflow2d3d.bat
% mdu_name=sprintf('sim_%s%s.mdu',runid_serie,runid_number);
% kl=1;
% data{kl,1}='@ echo off';                                        kl=kl+1;
% data{kl,1}=sprintf('call %s --autostartstop -t 1 %s',path_bat,mdu_name);kl=kl+1;
% data{kl,1}=':end';   
    %% FM
path_bat=fullfile(home,arch_s,'dimr','scripts','run_dimr.bat'); %c:\Users\chavarri\checkouts\oss_artifacts_x64_64757\x64\dflow2d3d\scripts\run_dflow2d3d.bat
kl=1;
data{kl,1}='@ echo off';               kl=kl+1;
data{kl,1}=sprintf('call %s',path_bat);kl=kl+1;
data{kl,1}=':end';   
    case 1
path_exe=fullfile(home,arch_s,'dflowfm\bin\dflowfm-cli.exe');
mdu_name=sprintf('sim_%s%s.mdu',runid_serie,runid_number);
kl=1;
data{kl,1}='@ echo off';                                        kl=kl+1;
data{kl,1}=sprintf('%s --autostartstop -t 1 %s',path_exe,mdu_name);                   kl=kl+1;
data{kl,1}=':end';                                              
    otherwise
        error('...')
        
end
% data{kl,1}='pause'; %uncomment will wait for input after simulation has finished

%% WRITE

% file_name=fullfile(dire_sim,'run_u.bat');
file_name=fullfile(dire_sim,'run.bat');
writetxt(file_name,data)