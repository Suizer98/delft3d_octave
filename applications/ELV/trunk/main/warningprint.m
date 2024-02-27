%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16592 $
%$Date: 2020-09-17 01:32:43 +0800 (Thu, 17 Sep 2020) $
%$Author: chavarri $
%$Id: warningprint.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/warningprint.m $
%
%warningprint does this and that
%
%warningprint(fid_log, text)
%
%INPUT:
%   -input = input structure
%
%OUTPUT:
%   -
%
%HISTORY:

function warningprint(fid_log, text)
if isnan(fid_log)==1
    warning('No log file specified, warning is only printed to the screen');
    warning(text);
else
    %   Display warning message
    %   Write output to logfile
    warning(text);
    fprintf(fid_log,'!!WARNING!!: %s \n',text);
end
end

