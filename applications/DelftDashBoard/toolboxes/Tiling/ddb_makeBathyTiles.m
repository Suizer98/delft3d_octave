function ddb_makeBathyTiles(dr, dataname, ncfiles, nrzoom, x00, y00, dx0, dy0, npx, npy, nx, ny, OPT)
%DDB_MAKEBATHYTILES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_makeBathyTiles(dr, dataname, ncfiles, nrzoom, x00, y00, dx0, dy0, npx, npy, nx, ny, OPT)
%
%   Input:
%   dr       =
%   dataname =
%   ncfiles  =
%   nrzoom   =
%   x00      =
%   y00      =
%   dx0      =
%   dy0      =
%   npx      =
%   npy      =
%   nx       =
%   ny       =
%   OPT      =
%
%
%
%
%   Example
%   ddb_makeBathyTiles
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

% $Id: ddb_makeBathyTiles.m 5560 2011-12-02 11:26:29Z boer_we $
% $Date: 2011-12-02 19:26:29 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5560 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tiling/ddb_makeBathyTiles.m $
% $Keywords: $

%%
dr=[dr dataname filesep];

imaketiles=1;
imakemeta=1;

x0(1)=x00;
y0(1)=y00;
dxk(1)=dx0;
dyk(1)=dy0;
nnxk(1)=ceil(npx/nx);
nnyk(1)=ceil(npy/ny);
nxk(1)=nx;
nyk(1)=ny;

for k=2:nrzoom
    x0(k)=x00;
    y0(k)=y00;
    dxk(k)=dxk(1)*2^(k-1);
    dyk(k)=dyk(1)*2^(k-1);
    nnxk(k)=ceil(nnxk(k-1)/2);
    nnyk(k)=ceil(nnyk(k-1)/2);
    nxk(k)=nx;
    nyk(k)=ny;
end

izoomstart=4;
izoomstop=nrzoom;

if imaketiles
    
    
    %    ddb_makeLowLevelTiles(dr,dataname,ncfiles,dxk,dyk,nnxk,nnyk,nxk,nyk,x0,y0,OPT);
    
    for k=izoomstart:izoomstop
        ddb_makeHighLevelTiles(dr,dataname,k,dxk,dyk,nnxk,nnyk,x0,y0,nxk,nyk,OPT);
    end
    
end

% Check which files are available and make meta file
if imakemeta
    ddb_createTilesMetaFile(dr,dataname,nrzoom,dxk,dyk,nnxk,nnyk,nxk,nyk,x0,y0,OPT);
end

