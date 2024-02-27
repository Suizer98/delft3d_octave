function ddb_saveAstroMapFile(fname, x, y, comp, amp, phi)
%DDB_SAVEASTROMAPFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveAstroMapFile(fname, x, y, comp, amp, phi)
%
%   Input:
%   fname =
%   x     =
%   y     =
%   comp  =
%   amp   =
%   phi   =
%
%
%
%
%   Example
%   ddb_saveAstroMapFile
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

% $Id: ddb_saveAstroMapFile.m 5560 2011-12-02 11:26:29Z boer_we $
% $Date: 2011-12-02 19:26:29 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5560 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/TideDatabase/ddb_saveAstroMapFile.m $
% $Keywords: $

%%
x(isnan(x))=-999;
y(isnan(y))=-999;

fid=fopen(fname,'wt');

fprintf(fid,'%s\n','* column 1 : x');
fprintf(fid,'%s\n','* column 2 : y');
for i=1:length(amp)
    fprintf(fid,'%s\n',['* column ' num2str(i*2+1) ' : Amplitude ' comp{i}]);
    fprintf(fid,'%s\n',['* column ' num2str(i*2+2) ' : Phase ' comp{i}]);
end
fprintf(fid,'%s\n','BL01');
fprintf(fid,'%i %i %i %i\n',size(x,1)*size(x,2),length(amp)*2+2,size(x,1),size(x,2));
for j=1:size(x,2)
    for i=1:size(x,1)
        zz=[];
        for k=1:length(amp)
            zz(k*2-1)=amp{k}(i,j);
            zz(k*2)=phi{k}(i,j);
        end
        zz(isnan(zz))=-999;
        fprintf(fid,['%12.4e %12.4e' repmat(' %12.4e',1,2*length(amp)) '\n'],x(i,j),y(i,j),zz);
    end
end
fclose(fid);

