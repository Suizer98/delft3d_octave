function [SOSdata]=ITHK_readSOS(filename)
%read SOS : reads a unibest sources and sinks file
%
%   Syntax:
%     [SOSdata]=ITHK_readSOS(filename)
%
%   Input:
%     filename             string with output filename
%
%   Output:
%     SOSdata              structure with SOS data
%                            .XW: [8x1 double]
%                            .YW: [8x1 double]
%                            .CODE: [8x1 double]
%                            .Qs: [8x1 double]
%                            .COLUMN: [8x1 double]
% 
%   Example:
%     ITHK_readSOS(filename)
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

% $Id: ITHK_readSOS.m 6382 2012-06-12 16:00:17Z boer_we $
% $Date: 2012-06-13 00:00:17 +0800 (Wed, 13 Jun 2012) $
% $Author: boer_we $
% $Revision: 6382 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/OLD/ITHK_readSOS.m $
% $Keywords: $

%-----------read data to file--------------
%-------------------------------------------

SOSdata=struct;
fid = fopen(filename,'rt');
lin=fgetl(fid);
SOSdata.headerline=lin;
lin=fgetl(fid);
nrs = str2num(lin);
SOSdata.nrsourcesandsinks=nrs;
lin=fgetl(fid);
for ii=1:nrs
    lin=fgetl(fid);
    [SOSdata.XW(ii,1)  SOSdata.YW(ii,1)  SOSdata.CODE(ii,1)  SOSdata.Qs(ii,1)  SOSdata.COLUMN(ii,1)]=strread(lin,'%f%f%f%f%f');
end
fclose(fid);
