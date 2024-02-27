function varargout = arc_info_binary2asc(varargin)
%arc_info_binary2asc  Read an arc/info binary grid and write to Arc ASCII Grid Format
%
%   The function reads an arc/info binary grid using arc_info_binary.
%   The data is the written to a file with the Arc ASCII Grid
%   Format (extension = .asc). The name of the binary and the ASCII file 
%   are the same.
%
%   Syntax:
%   varargout = arc_info_binary2asc(varargin)
%
%   Input:
%   varargin  = various key/value pairs possible (see arc_info_binary)
%               first parameter: 1. filename - the name of the arc/info binary
%                                              grid
%                                     or
%                                2. 'base',filename - the name of the 
%                                                     arc/info binary grid
%               additional parameter:
%                   'novalue',aValue: set all NaN values to aValue. Default
%                                     it is set to -99999.99
%
%   Output:
%   varargout = the possible out put from arc_info_binary (see help)
%                    D    = arc_info_binary(name)
%               [X,Y,D]   = arc_info_binary(name)
%               [X,Y,D,M] = arc_info_binary(name)
%
%   Example
%   d=arc_info_binary2asc(fname,'novalue',32444)
%
%   See also: arcgrid, arc_info_binary

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Lou Verhage
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created: 30 Sep 2010
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id: arc_info_binary2asc.m 10894 2014-06-26 09:13:22Z boer_g $
% $Date: 2014-06-26 17:13:22 +0800 (Thu, 26 Jun 2014) $
% $Author: boer_g $
% $Revision: 10894 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/gis/arc_info_binary2asc.m $
% $Keywords: $

%% set the defaults

nextarg = 1;
if odd(nargin)                
  OPT.base = varargin{1};
  nextarg = 2;
end

OPT.novalue = -99999.99;

OPT = setproperty(OPT,varargin{nextarg:end});

%% Read the arc/info grid file

[X,Y,D,M] = arc_info_binary(varargin{1:end});

%% write to the ASC file

%create asc file

OPT.base = [OPT.base,'.asc'];
fid      = fopen(OPT.base,'w');

%write header, example
%     ncols    500
%     nrows    625
%     xllcorner  260000.00
%     yllcorner  575000.00
%     cellsize      20.00
%     nodata_value  -9999.000

fprintf(fid,'ncols %i \n',M.nColumns);
fprintf(fid,'nrows %i \n',M.nRows);
fprintf(fid,['xllcorner %f \n'],M.D_LLX);
fprintf(fid,['yllcorner %f \n'],M.D_LLY);
fprintf(fid,['cellsize %f \n'],M.HPixelSizeX);
fprintf(fid,['nodata_value %f \n'],OPT.novalue);

%write data
D(isnan(D)) = OPT.novalue;

div = 20;
step = ceil(M.nColumns/div);
for r=1:M.nRows
    n1 = 1 - div;
    while (true)
        n1 = n1 + div;
        n2 = n1 + div - 1; 
        if n2 >= M.nColumns
            n2 = M.nColumns;
            s=[sprintf(' %f ',D(r,n1:n2))];
            fprintf(fid,'%s\n',s);
            break
        else
            s=[sprintf(' %f ',D(r,n1:n2))];
            fprintf(fid,'%s\n',s);
        end
    end
end    
    
fclose(fid);


%% output

if nargout==1
  varargout = {D};
elseif nargout==3
  varargout = {X,Y,D};
elseif nargout==4
  varargout = {X,Y,D,M};
end


