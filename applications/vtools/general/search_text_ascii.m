%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18307 $
%$Date: 2022-08-18 11:53:26 +0800 (Thu, 18 Aug 2022) $
%$Author: chavarri $
%$Id: search_text_ascii.m 18307 2022-08-18 03:53:26Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/search_text_ascii.m $
%
%find the line in an ascii file starting from a certain one that has certain text on it

function [kl_tok,fline_got]=search_text_ascii(path_ascii,tok_find,kl_start)

fid=fopen(path_ascii,'r');

kl=0;
kl_tok=[];
fline_got={};
while ~feof(fid)
    kl=kl+1;
    fline=fgetl(fid);
    if kl>kl_start
        bol=contains(fline,tok_find);
        if bol
            kl_tok=cat(1,kl_tok,kl);
            fline_got=cat(1,fline_got,fline);
%             fclose(fid);
%             return
        end %bol
    end %kl<kl_start
end %~feof(fid)

fclose(fid);

end %function

