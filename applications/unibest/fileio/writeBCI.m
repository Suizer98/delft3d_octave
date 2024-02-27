function writeBCI(filename, xy, varargin)
%write BCI : Writes a unibest internal wave boundary file
%
%   Syntax:
%     function writeBCI(filename, xy, Yoffset, BlockPerc, Yreference)
% 
%   Input:
%     filename             string with output filename
%     xy                   xy values ([Nx2] matrix or string with filename), note: if xy is empty, it is not required to specify parameters below (i.e. Yoffset, BlockPerc, Yreference)
%     Yoffset              top-definition of internal boundary ([Nx1] matrix in meters) (default = 0)
%     BlockPerc            blocking percentage ([Nx1] matrix in percentages) (default = 100%)
%     Yreference           reference of Yoffset (optional (default = 0) : [Nx1] matrix with 0 = relative to shoreline (i.e. y(t)) and 1 = absolute, i.e. relative to reference line) (default = 0)
%  
%   Output:
%     .bci file
%
%   Example:
%     writeBCI('test.bci', [32000,56000] , 55, 3.5, 0)
%     writeBCI('test.bci', [32000,56000])
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: writeBCI.m 8631 2013-05-16 14:22:14Z heijer $
% $Date: 2013-05-16 22:22:14 +0800 (Thu, 16 May 2013) $
% $Author: heijer $
% $Revision: 8631 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/writeBCI.m $
% $Keywords: $


%-----------Write data to file--------------
%-------------------------------------------
fid = fopen(filename,'wt');

if isstr(xy)
    dta=readldb(xy);
    xy=[dta.x dta.y];
end

if isempty(xy)
    no_internal_bounds=0;
else
    no_internal_bounds=size(xy,1);
end

Yoffset    = 0;
BlockPerc  = 100;
Yreference = 0;
if nargin==5
    Yoffset    = varargin{1};
    BlockPerc  = varargin{2};
    Yreference = varargin{3};
elseif nargin==4
    Yoffset    = varargin{1};
    BlockPerc  = varargin{2};
elseif nargin==3
    Yoffset    = varargin{1};
end
if length(Yoffset)==1
    Yoffset=repmat(Yoffset,[size(xy,1),1]);
end
if length(BlockPerc)==1
    BlockPerc=repmat(BlockPerc,[size(xy,1),1]);
end
if length(Yreference)==1
    Yreference=repmat(Yreference,[size(xy,1),1]);
end

if nargin>=2
    fprintf(fid,'NUMBER OF INTERNAL BOUNDARIES\n');
    fprintf(fid,'%4.0f\n',no_internal_bounds);
    fprintf(fid,'    XW        YW         TOP      BLOCK(%%)    KEY_AR\n');
    for ii=1:size(xy,1)
        fprintf(fid,' %9.2f %9.2f %9.2f %9.3f %9.0f\n',xy(ii,1),xy(ii,2),Yoffset(ii),BlockPerc(ii),Yreference(ii));
    end
else
    fprintf('\n incorrect number of input parameters!\n');
end
fclose(fid);
