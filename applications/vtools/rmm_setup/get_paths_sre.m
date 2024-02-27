%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: get_paths_sre.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/rmm_setup/get_paths_sre.m $
%

function paths=get_paths_sre(paths)

%%

paths.defrun_1=fullfile(paths.sre_out,'DEFRUN.1');

paths.defstr_4=fullfile(paths.sre_out,'DEFSTR.4');
paths.defstr_5=fullfile(paths.sre_out,'DEFSTR.5');

paths.defcnd_1=fullfile(paths.sre_out,'DEFCND.1');
paths.defcnd_2=fullfile(paths.sre_out,'DEFCND.2');
paths.defcnd_3=fullfile(paths.sre_out,'DEFCND.3');
paths.defcnd_6=fullfile(paths.sre_out,'DEFCND.6');

paths.defmet_1=fullfile(paths.sre_out,'DEFMET.1');

end %function