%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_bat_s.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_bat_s.m $
%
%bat file creation

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.D3D.home = full path to the folder where Delft3D is located [string] e.g. 'd:\victorchavarri\SURFdrive\programas\Delft3D\6.01.09.4278\'
%
%OUTPUT:
%   -a .bat compatible with D3D is created in file_name

function D3D_bat_s(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;
home=simdef.D3D.home;
switch simdef.D3D.arch
    case 1
        arch_s='win32'; 
    case 2
        switch simdef.D3D.compile
            case 0
                arch_s='x64';
            otherwise
                arch_s='win64'; 
        end
end

%% FILE
switch simdef.D3D.compile
    case 0
        %% problem with z layer
% % path_exe=fullfile(home,arch_s,'dflowfm\bin\dflowfm-cli.exe');
% path_scripts=fullfile(home,arch_s,'dflow2d3d','scripts');
% % mdu_name=sprintf('sim_%s%s.mdu',runid_serie,runid_number);
% kl=1;
% data{kl,1}='@ echo off'; kl=kl+1;
% data{kl,1}=sprintf('set scriptdir=%s',path_scripts); kl=kl+1;
% data{kl,1}='set dflowfmexedir=%scriptdir%\..\bin'; kl=kl+1;
% data{kl,1}='set "libdir=%scriptdir%\..\..\share\bin"'; kl=kl+1;
% data{kl,1}='set procdefbloomspedir=%scriptdir%\..\default'; kl=kl+1;
% data{kl,1}='set path=%dflowfmexedir%;%libdir%;%path%'; kl=kl+1;
% data{kl,1}='"%dflowfmexedir%\d_hydro.exe" config_flow2d3d.xml'; kl=kl+1;
% % data{kl,1}=sprintf('"%%dflowfmexedir%%\\d_hydro.exe" config_flow2d3d.xml',mdu_name); kl=kl+1;
% % data{kl,1}=sprintf('%s --autostartstop -t 1 %s',path_exe,mdu_name);                   kl=kl+1;
% data{kl,1}=':end';   
        %% better
path_bat=fullfile(home,arch_s,'dflow2d3d','scripts','run_dflow2d3d.bat'); %c:\Users\chavarri\checkouts\oss_artifacts_x64_64757\x64\dflow2d3d\scripts\run_dflow2d3d.bat
kl=1;
data{kl,1}='@ echo off';                                        kl=kl+1;
data{kl,1}=sprintf('call %s ',path_bat);kl=kl+1;
data{kl,1}=':end';                                              
    otherwise
kl=1;
data{kl,1}='@ echo off';                                        kl=kl+1;
data{kl,1}='set argfile=config_flow2d3d.xml';                   kl=kl+1;
data{kl,1}=sprintf('set ARCH=%s',arch_s);                   kl=kl+1;
data{kl,1}=sprintf('set home="%s"',home);                 kl=kl+1;
data{kl,1}='set exedir=%home%\%ARCH%\flow2d3d\bin';         kl=kl+1;
data{kl,1}='set PATH=%exedir%;%PATH%';                          kl=kl+1;
data{kl,1}='%exedir%\d_hydro.exe %argfile%';                    kl=kl+1;
data{kl,1}=':end';                                              
% data{kl,1}='pause'; %uncomment will wait for input after simulation has finished

end
%% WRITE

% file_name=fullfile(dire_sim,'run_flow2d3d.bat');
file_name=fullfile(dire_sim,'run.bat');

%check if the file already exists
if exist(file_name,'file')
    error('You are trying to overwrite a file!')
end

fileID_out=fopen(file_name,'w');
for kl=1:numel(data)
    fprintf(fileID_out,'%s\n',data{kl,1});
end

fclose(fileID_out);