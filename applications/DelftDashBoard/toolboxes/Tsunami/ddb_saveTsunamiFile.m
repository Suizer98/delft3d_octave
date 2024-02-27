function ddb_saveTsunamiFile(handles, filename)
%DDB_SAVETSUNAMIFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveTsunamiFile(handles, filename)
%
%   Input:
%   handles  =
%   filename =
%
%
%
%
%   Example
%   ddb_saveTsunamiFile
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
fid = fopen(filename,'w');

time=clock;
datestring=datestr(datenum(clock),31);

usrstring='- Unknown user';
usr=getenv('username');

if size(usr,1)>0
    usrstring=[' - File created by ' usr];
end

txt=['# ddb_tsunamiToolbox - DelftDashBoard v' handles.delftDashBoardVersion usrstring ' - ' datestring];
fprintf(fid,'%s \n',txt);

txt='';
fprintf(fid,'%s \n',txt);

txt=['Magnitude      ' num2str(handles.toolbox.tsunami.Magnitude)];
fprintf(fid,'%s \n',txt);

txt=['DepthFromTop   ' num2str(handles.toolbox.tsunami.DepthFromTop)];
fprintf(fid,'%s \n',txt);

if handles.toolbox.tsunami.RelatedToEpicentre
    txt=['RelatedToEpicentre   yes'];
    fprintf(fid,'%s \n',txt);
    txt=['Latitude       ' num2str(handles.toolbox.tsunami.Latitude)];
    fprintf(fid,'%s \n',txt);
    txt=['Longitude      ' num2str(handles.toolbox.tsunami.Longitude)];
    fprintf(fid,'%s \n',txt);
else
    txt=['RelatedToEpicentre   no'];
    fprintf(fid,'%s \n',txt);
end

txt=['NrSegments     ' num2str(handles.toolbox.tsunami.NrSegments)];
fprintf(fid,'%s \n',txt);
for i=1:handles.toolbox.tsunami.NrSegments
    txt=['Segment        ' num2str(handles.toolbox.tsunami.Dip(i)) ' ' num2str(handles.toolbox.tsunami.SlipRake(i))];
    fprintf(fid,'%s \n',txt);
end
for i=1:handles.toolbox.tsunami.NrSegments+1
    txt=['Vertex         ' num2str(handles.toolbox.tsunami.FaultX(i)) ' ' num2str(handles.toolbox.tsunami.FaultY(i))];
    fprintf(fid,'%s \n',txt);
end

fclose(fid);

