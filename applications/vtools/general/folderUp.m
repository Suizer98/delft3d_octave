%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17427 $
%$Date: 2021-07-22 18:14:33 +0800 (Thu, 22 Jul 2021) $
%$Author: chavarri $
%$Id: folderUp.m 17427 2021-07-22 10:14:33Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/folderUp.m $
%
%Get path of one folder up from a given one

function [folder2sendup_win,folder_last]=folderUp(folder2send_win)

pathsplit=regexp(folder2send_win,'\','split');
npath=numel(pathsplit);
folder2sendup_win=strcat(pathsplit{1,1},'\');
for kpath=2:npath-1
    folder2sendup_win=strcat(folder2sendup_win,pathsplit{1,kpath},'\');
end
folder_last=pathsplit{1,end};

end %function