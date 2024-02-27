%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17773 $
%$Date: 2022-02-18 14:02:30 +0800 (Fri, 18 Feb 2022) $
%$Author: chavarri $
%$Id: cartesify.m 17773 2022-02-18 06:02:30Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/cartesify.m $
%
%

function path_lin=cartesify(cartesius_project_folder_lin,path_win)

if isempty(cartesius_project_folder_lin)
    cartesius_project_folder_lin='projects/0/hisigem/';
end

path_lin=linuxify(path_win);
path_lin=strrep(path_lin,'/p/',cartesius_project_folder_lin);

end
