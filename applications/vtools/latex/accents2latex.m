%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17340 $
%$Date: 2021-06-10 21:24:14 +0800 (Thu, 10 Jun 2021) $
%$Author: chavarri $
%$Id: accents2latex.m 17340 2021-06-10 13:24:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/latex/accents2latex.m $
%
%transforms a string with accent to the LaTeX version

function str_auth=accents2latex(str_auth)
                
str_auth=strrep(str_auth,'ä','\"a');
str_auth=strrep(str_auth,'ë','\"e');
str_auth=strrep(str_auth,'ï','\"i');
str_auth=strrep(str_auth,'ö','\"o');
str_auth=strrep(str_auth,'ü','\"u');

str_auth=strrep(str_auth,'à','\`a');
str_auth=strrep(str_auth,'è','\`e');
str_auth=strrep(str_auth,'ì','\`i');
str_auth=strrep(str_auth,'ò','\`o');
str_auth=strrep(str_auth,'ù','\`u');

str_auth=strrep(str_auth,'á','\''a');
str_auth=strrep(str_auth,'Á','\''A');
str_auth=strrep(str_auth,'é','\''e');
str_auth=strrep(str_auth,'É','\''E');
str_auth=strrep(str_auth,'í','\''i');
str_auth=strrep(str_auth,'ó','\''o');
str_auth=strrep(str_auth,'ú','\''u');

% if strfind(str_auth,'Milivojevi')
%    s=1;
% end
% str_auth=strrep(str_auth,'','\''c'); %this only works in debug mode!
str_auth=strrep(str_auth,'ı','\''y');

str_auth=strrep(str_auth,'â','\^a');
str_auth=strrep(str_auth,'ê','\^e');
str_auth=strrep(str_auth,'î','\^i');
str_auth=strrep(str_auth,'ô','\^o');
str_auth=strrep(str_auth,'û','\^u');

str_auth=strrep(str_auth,'ã','\^a');

str_auth=strrep(str_auth,'ñ','\~n');

str_auth=strrep(str_auth,'š','\v{s}');
str_auth=strrep(str_auth,'Š','\v{S}');

str_auth=strrep(str_auth,'ç','\c{c}');

str_auth=strrep(str_auth,'“','``');
str_auth=strrep(str_auth,'‘','``');
str_auth=strrep(str_auth,'”','''''');
str_auth=strrep(str_auth,'’','''''');

str_auth=strrep(str_auth,'–','-');

str_auth=strrep(str_auth,'ß','{\ss}');
str_auth=strrep(str_auth,'ø','{\o}');

%DEBUG
% if strfind(str_auth,'Milivojevi')
%    s=1;
% end
%END DEBUG

end
