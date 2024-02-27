%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17374 $
%$Date: 2021-06-30 19:38:00 +0800 (Wed, 30 Jun 2021) $
%$Author: chavarri $
%$Id: oh_D3D_please_run.m 17374 2021-06-30 11:38:00Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/source/oh_D3D_please_run.m $
%

%% ERASE PREVIOUS SIMULATION

if erase_previous
   erase_folder(fullfile(simdef.D3D.paths_runs,simdef.runid.serie,simdef.runid.number),simdef.runid.serie,simdef.runid.number)
end

%% RENAME

% if exist('D3D_structure','var')
%     flg.D3D_structure=D3D_structure; 
% end
% if exist('D3D_home','var')
%     flg.D3D_home=D3D_home; %D3D location (string) if inexistent the default is 4278; e.g. 'd:\victorchavarri\SURFdrive\programas\Delft3D\6.01.09.4278\'
% end
% if exist('D3D_arch','var')
%     flg.D3D_arch=D3D_arch; %Architechture: 1=win32; 2=win64
% end
% if exist('paths_runs','var')
%     flg.paths_runs=paths_runs;
% end
% if isa(runid_number,'char')
%     runid.number=str2double(runid_number); 
% end

% runid.serie=runid_serie;    
% q.run=run_matlab; %run in matlab: 0=NO 1=YES

%% PATH DEFINITIONS

% source_path = pwd; 
% paths_auxiliary         = fullfile(source_path,'..',filesep,'auxiliary');
% paths_fcn               = fullfile(source_path,'..',filesep,'fcn');
% paths_input_generation  = fullfile(source_path,'..',filesep,'input_generation');
% paths_grid              = fullfile(source_path,'..',filesep,'grid');
% % paths_postprocessing    = fullfile(source_path,'..',filesep,'postprocessing');
% 
% % addpath('C:\Users\chavarri\surfdrive\projects\00_codes\matlab_functions\')

%% ADD PATHS

% %paths to add if they are not already added
% paths2add{1,1}=paths_fcn;
% paths2add{2,1}=paths_input_generation;       
% paths2add{3,1}=paths_auxiliary;
% paths2add{4,1}=paths_grid;
% 
% paths_inmatlab=regexp(path,pathsep,'split');
% for kp=1:numel(paths2add)
%     if ispc  % Windows is not case-sensitive
%       onPath=any(strcmpi(paths2add{kp,1},paths_inmatlab));
%     else
%       onPath=any(strcmp(paths2add{kp,1},paths_inmatlab));
%     end
%     if onPath==0
%         addpath(paths2add{kp,1});
%     end
% end

%% INPUT

run(simdef.runid.input_filename)

%% REWORK/OTHER

simdef=D3D_rework(simdef);
%create computer paths
% simdef=D3D_comp(simdef);

D3D_checkInput(simdef)

%check architecture
% if flg.D3D_arch~=2 && isempty(strfind(flg.D3D_home,'20161020_ellipticity_check'))~=1
%     warning('Ellipticity branch only working with win64 architecture')
% end

%% FILES CREATION

%create folder
mkdir(simdef.D3D.dire_sim)

%batch file	
D3D_bat(simdef)

%grid
D3D_grid(simdef)

%morphological boundary conditions
D3D_bcm(simdef)

%hydrodynamic boundary conditions 
D3D_bct(simdef)

%initial bathymetry
D3D_dep(simdef)
    
%initial bed grain size distribution
D3D_mini(simdef)

%initial flow conditions
if simdef.D3D.structure==1
D3D_fini(simdef)
end

%boundary definition
D3D_bnd(simdef)

%morphology parameters
D3D_mor(simdef)

%sediment parameters
D3D_sed(simdef)

%sediment transport parameters
if simdef.D3D.structure==1
D3D_tra(simdef)
end

%mdf/mdu
D3D_md(simdef)

%xml
D3D_xml(simdef)

%runid
if simdef.D3D.structure==1
D3D_runid(simdef)
end

%observation points
if simdef.mdf.Flhis_dt>0
D3D_obs(simdef) 
end

%save simulation definition
save(fullfile(simdef.D3D.dire_sim,'simdef.mat'),'simdef')

%% SIMULATION RUN

if simdef.D3D.run
    error('arreglar')
    D3D_run(file,runid)
end

%create folder
if exist(fullfile(simdef.D3D.dire_sim,'figures'),'dir')==0
    mkdir(simdef.D3D.dire_sim,'figures')
end

%display
fprintf('Ready! \n')