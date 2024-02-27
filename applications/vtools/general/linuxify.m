%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17778 $
%$Date: 2022-02-19 00:06:51 +0800 (Sat, 19 Feb 2022) $
%$Author: chavarri $
%$Id: linuxify.m 17778 2022-02-18 16:06:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/linuxify.m $
%
%

function path_lin=linuxify(path_win)

if strcmp(path_win(2),':') %windows path
    path_win=small_p(path_win);
    path_lin=strcat('/',path_win);
    path_lin=strrep(path_lin,':','');
    path_lin=strrep(path_lin,'\','/');
else
    path_lin=path_win;
end

end

%%
%% FUNCTIONS
%%

function path_dir=small_p(path_dir)

path_dir=strrep(path_dir,'P:','p:');

end %function