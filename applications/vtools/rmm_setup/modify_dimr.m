%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: modify_dimr.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/rmm_setup/modify_dimr.m $
%

function modify_dimr(path_xml,start_time,stop_time)

xml_in=read_ascii(path_xml);
nl=numel(xml_in);
for kl=1:nl
    tok=regexp(xml_in{kl,1},'<time>(\d+) (\d+) (\d+)</time>','tokens');
    if ~isempty(tok)
        xml_in{kl,1}=sprintf('        <time>%s %s %.0f</time>',tok{1,1}{1,1},tok{1,1}{1,2},seconds(stop_time-start_time));
    end
end
writetxt(path_xml,xml_in,'check_existing',0)

end %function