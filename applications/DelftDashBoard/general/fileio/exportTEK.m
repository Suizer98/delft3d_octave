function exportTEK(data, times, fname, blname, comments)
%EXPORTTEK  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   exportTEK(data, times, fname, blname, comments)
%
%   Input:
%   data     =
%   times    =
%   fname    =
%   blname   =
%   comments =
%
%
%
%
%   Example
%   exportTEK
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: exportTEK.m 5532 2011-11-28 17:56:41Z boer_we $
% $Date: 2011-11-29 01:56:41 +0800 (Tue, 29 Nov 2011) $
% $Author: boer_we $
% $Revision: 5532 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/fileio/exportTEK.m $
% $Keywords: $

%%
if size(data,1)==1
    data=data';
end

data(isnan(data))=-999;

fid=fopen(fname,'w');

if nargin==4
    fprintf(fid,'%s\n','* column 1 : Date');
    fprintf(fid,'%s\n','* column 2 : Time');
    fprintf(fid,'%s\n','* column 3 : WL');
else
    for ij=1:length(comments)
        fprintf(fid,'%s\n',comments{ij});
    end
end

fprintf(fid,'%s\n',blname);
n=size(data,1);
fprintf(fid,'%i %i\n',n,2+size(data,2));
fclose(fid);

datstr=datestr(times,'yyyymmdd HHMMSS');
wl=num2str(data,'%10.3f');
spc=repmat(' ',length(times),1);
str=[datstr spc wl];
dlmwrite(fname,str,'delimiter','','-append');


