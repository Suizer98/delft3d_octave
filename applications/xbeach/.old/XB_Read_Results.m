function XB = XB_Read_Results(resdir, XB, varargin)
%XB_READ_RESULTS  reads outputfiles
%
% Routine reads output files and stores the results in the XBeach
% communication variable XB.
%
% Syntax:
%   XB = XB_Read_Results(resdir, XB, 'outparam1', 'outparam2')
%   XB = XB_Read_Results(resdir, XB,'all')
%   XB = XB_Read_Results(resdir, XB)
%   XB = XB_Read_Results(...,'nodisp')
%   XB = XB_Read_Results(...,'quiet')
%
% Input:
%   resdir  = dir in which result can be found
%   XB      = XBeach communication structure created with CreateEmptyXBeachVar
%   outparam= Names of the (Xbeach output-)variables that have to be loaded
%   'nodisp'= Do not display messages in the command window
%   'quiet' = Do not show progress bar
%   '3d'    = Reads all output variables as 3D matrices (n*m*nt). Omitting
%               this specification leads to the same result, but only at
%               m=2;
%
% Output:
%   XB      = XBeach communication structure
%
% See also CreateEmptyXBeachVar XBeach_Write_Inp XB_Run

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Pieter van Geer
%
%       Pieter.vanGeer@deltares.nl	
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

% $Id: XB_Read_Results.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/XB_Read_Results.m $
% $Keywords: $


%%
ddd = false;
quiet = false;
nodisp = false;
varsdef = false;
if nargin==1
    XB = CreateEmptyXBeachVar;
end
if nargin>2
    if any(strcmpi(varargin,'3d'))
        ddd = true;
        varargin(strcmpi(varargin,'3d'))=[];
    end
    if any(strcmpi(varargin,'nodisp'))
        nodisp = true;
        varargin(strcmpi(varargin,'nodisp'))=[];
    end
    if any(strcmpi(varargin,'quiet'))
        quiet = true;
        varargin(strcmpi(varargin,'quiet'))=[];
    end
    varsdef = false;
    if ~isempty(varargin)
        varsdef = true;
        vars = varargin;
    end
end
%% dimensions
if ~quiet
    hwb = waitbar(0,'Reading dimensions');
end
try
    XBdims = xb_getdimensions(resdir);

    XB.Output.nt = XBdims.nt;
    XB.Output.nx = XBdims.nx + 1;
    XB.Output.ny = XBdims.ny + 1;
catch
    if ~quiet
        close(hwb);
    end
    error('XBEACHREAD:NODIMS',['Could not find the file: ' fullfile(resdir, 'dims.dat')]);
end

%% read grid coordinates
if ~quiet
    hwb = waitbar(0,hwb,'Reading xy.dat');
end
try
    XB.Output.xw = XBdims.x;
    XB.Output.yw = XBdims.y;
    XB.Output.x = XBdims.xc;
    XB.Output.y = XBdims.yc;
catch
    if ~quiet
        close(hwb);
    end
    error('XBEACHREAD:NOXY',['Could not find the file: ' resdir filesep 'xy.dat']);
end
    
%% read XBeach output

if varsdef
    nam = repmat({''},size(vars));
    for ivars = 1:length(vars)
        nam{ivars} = [vars{ivars} '.dat'];
    end
else
    nam=dir([resdir filesep '*.dat']);
    nam={nam.name}';
end
nam(~cellfun(@isempty,strfind(nam,'xy.dat')))=[];
nam(~cellfun(@isempty,strfind(nam,'dims.dat')))=[];
nam(~cellfun(@isempty,strfind(nam,XB.settings.Flow.zs0file)))=[];
nam(~cellfun(@isempty,strfind(nam,XB.settings.Waves.bcfile)))=[];

for j = 1:length(nam)
    if ~quiet
        hwb = waitbar(j/length(nam),hwb,['Reading ' nam{j}]);
    end
    temp = xb_readvar(fullfile(resdir, nam{j}), XBdims, '2D');
    [dummy name] = fileparts(nam{j});
    if ddd
        XB.Output.(name) = temp;
    else
        XB.Output.(name) = zeros(XB.Output.nx,XB.Output.nt);
        XB.Output.(name) = squeeze(temp(:,2,:));
    end
end
if ~quiet
    close(hwb);
end
