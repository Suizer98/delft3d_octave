function writetekalmap(fname, x, y, varargin)
%WRITETEKALMAP One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   writetekalmap(fname, x, y, varargin)
%
%   Input:
%   fname =
%   x     =
%   y     =
%
%   Example
%   [x,y] = meshgrid(1:100,1:50)
%   zpos = cos(x) + cos(y)
%   zneg = -zpos
%   writetekalmap('test.tek',x,y,'xpositive',zpos,'znegative',zneg)
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

% $Id: writetekalmap.m 8352 2013-03-19 08:43:30Z lescins $
% $Date: 2013-03-19 16:43:30 +0800 (Tue, 19 Mar 2013) $
% $Author: lescins $
% $Revision: 8352 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/fileio/writetekalmap.m $
% $Keywords: $

%%
x(isnan(x))=-999;
y(isnan(y))=-999;

nin=0;
for ii=1:length(varargin)
    if ischar(varargin{ii})
        nin=nin+1;
        par{nin}=varargin{ii};
        z0=varargin{ii+1};
        z(:,:,nin)=z0;
    end
end
        
z(isnan(z))=-999;

fid=fopen(fname,'wt');

fprintf(fid,'%s\n','* column 1 : x');
fprintf(fid,'%s\n','* column 2 : y');
for ii=1:length(par)
    fprintf(fid,'%s\n',['* column ' num2str(ii+2) ' : ' par{ii}]);
end
fprintf(fid,'%s\n','BL01');
fprintf(fid,'%i %i %i %i\n',size(x,1)*size(x,2),2+length(par),size(x,1),size(x,2));
for j=1:size(x,2)
    for i=1:size(x,1)
        zz=z(i,j,:);
        fprintf(fid,['%14.6e %14.6e ' repmat(' %14.6e',1,length(zz)) '\n'],x(i,j),y(i,j),zz);
    end
end
fclose(fid);
