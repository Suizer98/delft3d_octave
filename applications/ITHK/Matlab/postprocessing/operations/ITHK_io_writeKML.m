function ITHK_io_writeKML(kmltxt,addtxt,sens)
% ITHK_KMLdisclaimer(sens)
%
% writes kml-txt to a KMLfile
% addtxt is the extension that can be provided to the filename.

%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares for Building with Nature
%       Bas Huisman
%
%       Bas.Huisman@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id: ITHK_io_writeKML.m 10805 2014-06-04 08:10:15Z boer_we $
% $Date: 2014-06-04 16:10:15 +0800 (Wed, 04 Jun 2014) $
% $Author: boer_we $
% $Revision: 10805 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/postprocessing/operations/ITHK_io_writeKML.m $
% $Keywords: $

global S

fprintf(['ITHK postprocessing : Writing KML-file ''',S.userinput.name,addtxt,'.kml''\n']);

tvec            = S.PP(sens).settings.tvec;
tvec(length(tvec)+1)=round(2*tvec(end)-tvec(end-1));
t0              = S.PP(sens).settings.t0;
timeStamp      = datestr(datenum(tvec(end)+t0-1/365/24/60/60,1,1),'yyyy-mm-ddTHH:MM:SSZ');
LookAtLon      = str2double(S.settings.LookAtLon);%4.238448851166381;
LookAtLat      = str2double(S.settings.LookAtLat);%52.05719214488921;
LookAtAltitude = 0;
LookAtrange    = str2double(S.settings.LookAtRange);%50000;
LookAtheading  = 0;
LookAttilt     = 0;

%% WRITE KML
S.PP(sens).output.kmlFileName  = [S.settings.outputdir S.userinput.name addtxt '.kml'];  % KML filename settings
KMLmapName                     = S.userinput.name;
fid                            = fopen(S.PP(sens).output.kmlFileName,'w');
kmltxt                         = strrep(kmltxt,'\','\\');
kmltxt                         = strrep(kmltxt,'%','\%');
ids                            = int32([0:length(kmltxt)/9:length(kmltxt)-length(kmltxt)/9,length(kmltxt)]);
for ii=2:length(ids)-1
   if strcmp(kmltxt(ids(ii)+1),'\') || strcmp(kmltxt(ids(ii)+1),'%')
       ids(ii)=min(ids(ii)+2,max(ids)-1);
       if strcmp(kmltxt(ids(ii)+1),'\') || strcmp(kmltxt(ids(ii)+1),'%')
         ids(ii)=min(ids(ii)+1,max(ids)-1);
       end
   end
end
fprintf(fid,[ITHK_KMLheader('kmlName',KMLmapName,'timeStamp',timeStamp,'LookAtLon',LookAtLon,...
                        'LookAtLat',LookAtLat,'LookAtAltitude',LookAtAltitude,...
                        'LookAtrange',LookAtrange,'LookAttile',LookAttilt,...
                        'LookAtheading',LookAtheading)],'interpreter','off');
for ii=1:length(ids)-1
    fprintf(fid,[kmltxt(ids(ii)+1:ids(ii+1))],'interpreter','off');
end
fprintf(fid,[KML_footer],'interpreter','off');
fclose(fid);
end





