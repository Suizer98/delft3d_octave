%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17778 $
%$Date: 2022-02-19 00:06:51 +0800 (Sat, 19 Feb 2022) $
%$Author: chavarri $
%$Id: scpfy.m 17778 2022-02-18 16:06:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/scpfy.m $
%
%

function path_disp=scpfy(path_win,varargin)

parin=inputParser;

addOptional(parin,'cartesiusProject','/projects/0/hisigem/');
addOptional(parin,'cartesiusUser','pr1n0147');
% addOptional(parin,'cartesiusComputer','cartesius.surfsara.nl');
addOptional(parin,'cartesiusComputer','snellius.surf.nl');
addOptional(parin,'direction',1);

parse(parin,varargin{:});

user_cartesius=parin.Results.cartesiusUser;
cartesius_project_folder_lin=parin.Results.cartesiusProject;
computer_cartesius=parin.Results.cartesiusComputer;
direction=parin.Results.direction;
    
switch direction
    case 1 %send
        path_disp=sprintf('scp %s %s@%s:%s',linuxify(path_win),user_cartesius,computer_cartesius,cartesify(cartesius_project_folder_lin,path_win));
    case -1 %receive
        path_disp=sprintf('rsync -av --bwlimit=5000 %s@%s:%s %s',user_cartesius,computer_cartesius,cartesify(cartesius_project_folder_lin,path_win),linuxify(path_win));
end

end

%%
%% FUNCTIONS
%%

function path_dir=small_p(path_dir)

path_dir=strrep(path_dir,'P:','p:');

end %function