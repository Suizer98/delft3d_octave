function ddb_makeHighLevelTiles(dr, dataname, k, dxk, dyk, nnxk, nnyk, x0, y0, nxk, nyk, OPT)
%DDB_MAKEHIGHLEVELTILES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_makeHighLevelTiles(dr, dataname, k, dxk, dyk, nnxk, nnyk, x0, y0, nxk, nyk, OPT)
%
%   Input:
%   dr       =
%   dataname =
%   k        =
%   dxk      =
%   dyk      =
%   nnxk     =
%   nnyk     =
%   x0       =
%   y0       =
%   nxk      =
%   nyk      =
%   OPT      =
%
%
%
%
%   Example
%   ddb_makeHighLevelTiles
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

% $Id: ddb_makeHighLevelTiles.m 5560 2011-12-02 11:26:29Z boer_we $
% $Date: 2011-12-02 19:26:29 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5560 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tiling/ddb_makeHighLevelTiles.m $
% $Keywords: $

%%
if ~exist([dr 'zl' num2str(k,'%0.2i')],'dir')
    mkdir([dr 'zl' num2str(k,'%0.2i')]);
end

dx=dxk(k);
dy=dyk(k);
nnx=nnxk(k);
nny=nnyk(k);
nx=nxk(k);
ny=nyk(k);

iex0=zeros(2*nnx,2*nny);

flist=dir([dr 'zl' num2str(k-1,'%0.2i') '\*.nc']);

for i=1:length(flist)
    ii=str2double(flist(i).name(end-13:end-9));
    jj=str2double(flist(i).name(end-7:end-3));
    iex0(ii,jj)=1;
end

for i=1:nnx
    for j=1:nny
        
        disp(['Processing ' num2str((i-1)*nny+j) ' of ' num2str(nnx*nny) ' ...']);
        
        iind=[i*2-2 i*2-1 i*2 i*2+1];
        jind=[j*2-2 j*2-1 j*2 j*2+1];
        
        iex=zeros(4,4);
        ii1=1;
        ii2=4;
        jj1=1;
        jj2=4;
        
        
        if i==1
            ii1=2;
            ii2=4;
        end
        if i==nnx
            ii1=1;
            ii2=3;
        end
        if j==1
            jj1=2;
            jj2=4;
        end
        if j==nny
            jj1=1;
            jj2=3;
        end
        iex(ii1:ii2,jj1:jj2)=iex0(iind(ii1):iind(ii2),jind(jj1):jind(jj2));
        
        if max(max(iex))>0
            
            % Now get the surrounding files and merge them
            
            zz=zeros(4*ny,4*nx);
            zz(zz==0)=NaN;
            
            for ii=1:4
                for jj=1:4
                    if iex(ii,jj)
                        fname=[dr 'zl' num2str(k-1,'%0.2i') '\' dataname '.zl' num2str(k-1,'%0.2i') '.' num2str(iind(ii),'%0.5i') '.' num2str(jind(jj),'%0.5i') '.nc'];
                        ncid = netcdf.open (fname,'NOWRITE');
                        varid = netcdf.inqVarID(ncid,'depth');
                        z = netcdf.getVar(ncid,varid);
                        z=double(z);
                        z=z';
                        netcdf.close(ncid);
                        z(z==-9999)=NaN;
                    else
                        z=zeros(ny,nx);
                        z(z==0)=NaN;
                    end
                    
                    zz((jj-1)*ny+1:jj*ny,(ii-1)*nx+1:ii*nx)=z;
                    
                end
            end
            
            % Now crop and derefine tile
            
            %                        zz=zz(ny-1:3*ny-1,nx-1:3*nx-1);
            zz=zz(ny:3*ny,nx:3*nx);
            z=derefine3(zz);
            z=z';
            
            if ~isempty(find(~isnan(z), 1))
                z=single(z);
                
                xmin = x0(k)+(i-1)*nx*dx;
                ymin = y0(k)+(j-1)*ny*dy;
                xmax = xmin+(nx-1)*dx;
                ymax = ymin+(ny-1)*dy;
                
                xx=xmin:dx:xmax;
                yy=ymin:dy:ymax;
                
                fname=[dr 'zl' num2str(k,'%0.2i') '\' dataname '.zl' num2str(k,'%0.2i') '.' num2str(i,'%0.5i') '.' num2str(j,'%0.5i') '.nc'];
                
                z(isnan(z))=-9999;
                z=int16(z);
                
                nc_grid_createNCfile2(fname,xx,yy,z,OPT);
                
            end
        end
    end
end

