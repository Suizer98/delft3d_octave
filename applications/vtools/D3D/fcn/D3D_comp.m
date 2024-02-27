%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17374 $
%$Date: 2021-06-30 19:38:00 +0800 (Wed, 30 Jun 2021) $
%$Author: chavarri $
%$Id: D3D_comp.m 17374 2021-06-30 11:38:00Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_comp.m $
%
%computer name and path

function simdef=D3D_comp(simdef)

warning('deprecated')

%% SET PATHS

[~,simdef.D3D.hostname]=system('hostname');

%% D3D structure
% if isfield(flg,'D3D_structure')==0
%     file.D3D_structure=1;
% else
%     file.D3D_structure=flg.D3D_structure;
% end
    
%% D3D version
% if isfield(flg,'D3D_home')==0
%     switch simdef.D3D.hostname(1:end-1)
%         case {'TUD276800','TUD0043086','TUD206003','TUD276802'}
%             file.D3D_home='d:\victorchavarri\SURFdrive\programas\Delft3D\6.01.09.4278\';
%         case 'VLM031544'
%             file.D3D_home='c:\Victor\programas\Delft3D\6.01.09.4278\';
%         otherwise
%             error('The paths to the computer you are using are not defined')
%     end
% else
%     file.D3D_home=flg.D3D_home;
% end

%% D3D architecture
%not necessary for plotting
% if isfield(flg,'D3D_arch')==1
%     file.D3D_arch=flg.D3D_arch;
% end

%% OPENEARTH TOOLS

% try
%     oetroot;
% catch
%     switch simdef.D3D.hostname(1:end-1)
%         case {'TUD276800','TUD0043086','TUD206003','TUD276802'}
%             file.checkouts='d:\checkouts\OpenEarthTools\matlab\oetsettings.m';
%         case 'VLM031544'
%             file.checkouts='c:\Victor\programas\checkouts\OpenEarthTools\matlab\oetsettings.m';
%         case {'L00708','V-WCF044'}
%             file.checkouts='c:\Users\chavarri\checkouts\openearthtools_matlab\oetsettings.m';
%         otherwise
%             error('The paths to the computer you are using are not defined')
%     end
% end

%% MAIN SERIE FOLDER
% if isfield(flg,'dire_sim')==0 %if dire_sim already exists, main_folder is unecessary
% if isfield(flg,'paths_runs')==0
%     switch simdef.D3D.hostname(1:end-1)
%         case 'TUD276800'
%             if flg.disk==1
%                 flg.paths_runs='d:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\';
%             else
%                 flg.paths_runs='g:\data\projects\ellipticity\D3D\runs\';  
%             end
%         case 'TUD0043086'
%             if flg.disk==1
%                 flg.paths_runs='d:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\';
%             else
%                 flg.paths_runs='c:\Users\victorchavarri\temporal\D3D\runs\';  
%             end
%         case 'VLM031544'
%             flg.paths_runs='c:\Victor\D3D\runs\';
%         case 'TUD206003'
%             flg.paths_runs='d:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\';
%         case 'TUD276802'
%             flg.paths_runs='d:\victorchavarri\D3D\runs\';
%     end
% else
%     
% end
%     file.main_folder=fullfile(flg.paths_runs,runid.serie);
% end

%% DIRE SIM
% if isfield(simdef.D3D,'dire_sim')==0 || isempty(simdef.D3D.dire_sim)
%     if strcmp(simdef.runid.serie,'Rhine')
%         simdef.D3D.dire_sim=fullfile(file.main_folder,sprintf('%02d',runid.number));
%     else
%         simdef.D3D.dire_sim=fullfile(simdef.D3D.paths_runs,simdef.runid.serie,simdef.runid.number);
%     end
% end

%% GRID

% if isfield(simdef.D3D,'dire_grid')==0
%     source_path=pwd; 
%     simdef.D3D.dire_grid=fullfile(source_path,'..',filesep,'grid');    
% else
%     
% end
