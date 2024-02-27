function [X Y Z] = readhtmldata(filename, varargin)
%READHTMLDATA  Reads bathymetri data from html file
%
%   More detailed description goes here.
%
%   Syntax:
%   [X Y Z] = readhtmldata(filename)
%
%   Input:
%   filename = string
%   varargin = 'PropertyName'-PropertyValue pairs
%       'Xcolumn'   (default = 6)
%       'Ycolumn'   (default = 7)
%       'Zcolumn'   (default = 8)
%
%   Output:
%   X = x-coordinates
%   Y = y-coordinates
%   Z = z-coordinates
%
%   Example
%   readhtmldata('myfile.html')
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Dano Roelvink / Ap van Dongeren / C.(Kees) den Heijer
%
%       Kees.denHeijer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 03 Feb 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: readhtmldata.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/xb_grid/readhtmldata.m $

%%
OPT = struct(...
    'Xcolumn', 6,...
    'Ycolumn', 7,...
    'Zcolumn', 8);

OPT = setproperty(OPT, varargin{:});

%%
[X Y Z] = deal([]);

if exist('filename', 'file')
    XYZ = load(filename);

    X = XYZ(:,OPT.Xcolumn);
    Y = XYZ(:,OPT.Ycolumn);
    Z = XYZ(:,OPT.Zcolumn);
else
    fprintf('File not found\n');
end