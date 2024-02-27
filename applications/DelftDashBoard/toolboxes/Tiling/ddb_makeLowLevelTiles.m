function ddb_makeLowLevelTiles(dr, dataname, ncfiles, dxk, dyk, nnxk, nnyk, nxk, nyk, x0, y0, OPT)
%DDB_MAKELOWLEVELTILES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_makeLowLevelTiles(dr, dataname, ncfiles, dxk, dyk, nnxk, nnyk, nxk, nyk, x0, y0, OPT)
%
%   Input:
%   dr       =
%   dataname =
%   ncfiles  =
%   dxk      =
%   dyk      =
%   nnxk     =
%   nnyk     =
%   nxk      =
%   nyk      =
%   x0       =
%   y0       =
%   OPT      =
%
%
%
%
%   Example
%   ddb_makeLowLevelTiles
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

% $Id: ddb_makeLowLevelTiles.m 5560 2011-12-02 11:26:29Z boer_we $
% $Date: 2011-12-02 19:26:29 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5560 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tiling/ddb_makeLowLevelTiles.m $
% $Keywords: $

%%
for i=1:length(ncfiles)
    x=nc_varget(ncfiles{i},'lon');
    y=nc_varget(ncfiles{i},'lat');
    xmn(i)=x(1);
    xmx(i)=x(end);
    ymn(i)=y(1);
    ymx(i)=y(end);
end

k=1; % Lowest level

if ~exist([dr 'zl' num2str(k,'%0.2i')],'dir')
    mkdir([dr 'zl' num2str(k,'%0.2i')]);
end

dx=dxk(k);
dy=dyk(k);
nnx=nnxk(k);
nny=nnyk(k);
nx=nxk(k);
ny=nyk(k);

%for i=1:nnx
for i=694:nnx
    for j=1:nny
        
        disp(['Processing ' num2str((i-1)*nny+j) ' of ' num2str(nnx*nny) ' ...']);
        
        xmin = x0(k)+(i-1)*nx*dx;
        ymin = y0(k)+(j-1)*ny*dy;
        xmax = xmin+(nx-1)*dx;
        ymax = ymin+(ny-1)*dy;
        
        xx=xmin:dx:xmax;
        yy=ymin:dy:ymax;
        
        ifile=find(xmn<=xmin+1e-5 & xmx>=xmin & ymn<=ymin+1e-5 & ymx>=ymin);
        
        if ~isempty(ifile)
            i1=round((xmin-xmn(ifile))/dx);
            j1=round((ymin-ymn(ifile))/dy);
            %                zz=nc_varget(ncfiles{ifile},'depth',[j1 i1],[ny nx]);
            zz=nc_varget(ncfiles{ifile},'depth',[i1 j1],[nx ny]);
            %                zz=double(zz);
            %                zz(zz<-9998&zz>-10000)=NaN;
            %            if ~isnan(max(max(zz)))
            if ~isempty(find(zz~=-9999, 1))
                %                zz=single(zz);
                %                zz=zz';
                fname=[dr 'zl' num2str(k,'%0.2i') '\' dataname '.zl01.' num2str(i,'%0.5i') '.' num2str(j,'%0.5i') '.nc'];
                nc_grid_createNCfile2(fname,xx,yy,zz,OPT);
            end
        end
        
    end
end

