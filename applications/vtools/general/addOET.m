%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18127 $
%$Date: 2022-06-09 18:38:32 +0800 (Thu, 09 Jun 2022) $
%$Author: chavarri $
%$Id: addOET.m 18127 2022-06-09 10:38:32Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/addOET.m $
%
%This does A and B
%
%INPUT:
%
%OUTPUT:
%

function addOET(path_v_gen)

if exist('oetsettings','file')~=2
    
    %% parse

    path_oet=fullfile(path_v_gen,'../','../','../','oetsettings.m');
    path_oet=strrep(path_oet,'\','/');

    %% modify path
    
    %when running in Cartesius, the path needed to be modified. 
    %if necessary, uncomment and clean this part of the code
    %making it general enough
    
%     switch path_oet(1)
%         case 'p'
%     end
% 
%     [~,name]=system('hostname');
%     if ispc
%     %     path_drive_p='p:\';
%     elseif isunix        
%         if contains(name,'bullx') %cartesius
%             path_oet(1:3)='';
%             path_oet=fullfile('/projects/0/hisigem/',path_oet);
%         end
%     else
%         error('adapt the paths')
%     end

    %% add repository
    
    fprintf('Start adding repository at %s \n',path_oet);
    run(path_oet);
else
    path_oet=which('oetsettings');
end

fprintf('Using repository at %s \n',path_oet)

end %function