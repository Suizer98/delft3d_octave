function makeNCBathyTiles(fname1, dr, dataname, rawdatatype, nrzoom, nx, ny, OPT)
%MAKENCBATHYTILES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   makeNCBathyTiles(fname1, dr, dataname, nrzoom, nx, ny, OPT)
%
%   Input:
%   fname1   =
%   dr       =
%   dataname =
%   nrzoom   =
%   nx       =
%   ny       =
%   OPT      =
%
%
%
%
%   Example
%   makeNCBathyTiles
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

% $Id: makeNCBathyTiles.m 8764 2013-06-03 12:16:59Z ormondt $
% $Date: 2013-06-03 20:16:59 +0800 (Mon, 03 Jun 2013) $
% $Author: ormondt $
% $Revision: 8764 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tiling/makeNCBathyTiles.m $
% $Keywords: $

%%

switch lower(rawdatatype)
    case{'arcinfogrid'}
        wb = waitbox('Reading data file ...');
        [ncols,nrows,x00,y00,dx0]=readArcInfo(fname1,'info');
        close(wb);
    case{'arcbinarygrid'}
        wb = waitbox('Reading data file ...');
        [x,y,z,m] = arc_info_binary([fileparts(fname1) filesep]);
        close(wb);
        z=flipud(z);
        y=fliplr(y);
        x00=m.X(1);
        y00=m.Y(end);
        dx0=m.X(2)-m.X(1);
        ncols=m.nColumns;
        nrows=m.nRows;
    case{'matfile'}
        wb = waitbox('Reading data file ...');
        s=load(fname1);
        z=s.z;
        x00=s.x(1);
        y00=s.y(1);
        nrows=length(s.y);
        dx0=s.x(2)-s.x(1);
        ncols=length(s.x);
        close(wb);
    case{'netcdf'}
        wb = waitbox('Reading data file ...');
        x=nc_varget(fname1,'x');
        y=nc_varget(fname1,'y');
        z=nc_varget(fname1,'z');
        x00=x(1);
        y00=y(1);
        nrows=length(y);
        dx0=x(2)-x(1);
        ncols=length(x);
        close(wb);
end

pbyp=0;

if ncols*nrows>250000000000
    % Too large, read piece by piece...
    pbyp=1;
else
    % Read in one go!
    switch lower(rawdatatype)
        case{'arcinfogrid'}
            [x,y,z]=readArcInfo(fname1);
    end
end
if ~OPT.positiveup
    z=z*-1;
end

imaketiles=1;
imakemeta=1;

x0(1)=x00;
y0(1)=y00;
dxk(1)=dx0;
dyk(1)=dx0;
nnxk(1)=ceil(ncols/nx);
nnyk(1)=ceil(nrows/ny);
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

if imaketiles
    
    for k=1:nrzoom
        
        if ~exist([dr 'zl' num2str(k,'%0.2i')],'dir')
            mkdir([dr 'zl' num2str(k,'%0.2i')]);
        end
        
        dx=dxk(k);
        dy=dyk(k);
        nnx=nnxk(k);
        nny=nnyk(k);

        
        if k==1

            wb = awaitbar(0,'Generating tiles ...');
            
            tilen=0;

            for i=1:nnx
                for j=1:nny

                    tilen=tilen+1;

                    str=['Generating tiles - tile ' num2str(tilen) ' of ' ...
                        num2str(nnx*nny) ' ...'];
                    [hh,abort2]=awaitbar(tilen/(nnx*nny),wb,str);
                    
                    if abort2 % Abort the process by clicking abort button
                        break;
                    end;
                    if isempty(hh); % Break the process when closing the figure
                        break;
                    end;

                    disp(['Processing ' num2str((i-1)*nny+j) ' of ' num2str(nnx*nny) ' ...']);
                    
                    xmin = x0(k)+(i-1)*nx*dx;
                    ymin = y0(k)+(j-1)*ny*dy;
                    xmax = xmin+(nx-1)*dx;
                    ymax = ymin+(ny-1)*dy;
                    
                    xx=xmin:dx:xmax;
                    yy=ymin:dy:ymax;
                    
                    i1=(i-1)*nx+1;
                    i2=i*nx;
                    i2=min(i2,ncols);
                    j1=(j-1)*ny+1;
                    j2=j*ny;
                    j2=min(j2,nrows);
                    
                    zz=nan(ny,nx);
                    
                    if pbyp
                        % Read data piece by piece
                        %                        [x,y,z]=readArcInfo(fname1,'columns',[j1 j2],'rows',[i1 i2],'x',xx,'y',yy);
                        [x,y,zz]=readArcInfo(fname1,'x',xx,'y',yy);
                        %                        zz(1:(j2-j1+1),1:(i2-i1+1))=single(z);
                    else
                        zz(1:(j2-j1+1),1:(i2-i1+1))=single(z(j1:j2,i1:i2));
                    end
                    
                    %                    zz(1:(j2-j1+1),1:(i2-i1+1))=single(z(j1:j2,i1:i2));
                    % Only save files that contain at least some valid
                    % values
                    if ~isnan(nanmax(nanmax(zz)))
                        zz=single(zz);
                        zz=zz';
                        fname=[dr 'zl' num2str(k,'%0.2i') '\' dataname '.zl01.' num2str(i,'%0.5i') '.' num2str(j,'%0.5i') '.nc'];
                        
                        OPT.fillValue=-999;
                        
                        nc_grid_createNCfile2(fname,xx,yy,zz,OPT);
                    end
                    
                end
            end
            
            % Close waitbar
            if ~isempty(hh)
                close(wb);
            end
            
        else
                        
            % Get tiles from lower zoom level
            
            wb = awaitbar(0,'Generating tiles ...');
            
            tilen=0;
            
            for i=1:nnx
                for j=1:nny
                    
                    tilen=tilen+1;

                    str=['Generating level ' num2str(k) ' of ' num2str(nrzoom) ' - tile ' num2str(tilen) ' of ' ...
                        num2str(nnx*nny) ' ...'];
                    [hh,abort2]=awaitbar(tilen/(nnx*nny),wb,str);
                    
                    if abort2 % Abort the process by clicking abort button
                        break;
                    end;
                    if isempty(hh); % Break the process when closing the figure
                        break;
                    end;
                    
                    disp(['Processing ' num2str((i-1)*nny+j) ' of ' num2str(nnx*nny) ' ...']);
                    
                    iind=[i*2-2 i*2-1 i*2 i*2+1];
                    jind=[j*2-2 j*2-1 j*2 j*2+1];
                    
                    iex=zeros(4,4);
                    
                    % First check if surrouning files exist
                    for ii=1:4
                        for jj=1:4
                            fname=[dr 'zl' num2str(k-1,'%0.2i') '\' dataname '.zl' num2str(k-1,'%0.2i') '.' num2str(iind(ii),'%0.5i') '.' num2str(jind(jj),'%0.5i') '.nc'];
                            if exist(fname,'file')
                                iex(ii,jj)=1;
                            end
                        end
                    end
                    
                    if max(max(iex))>0
                        
                        % Now get the surrounding files and merge them
                        %                          figure(1)
                        %                          clf
                        %
                        zz=zeros(4*ny,4*nx);
                        zz(zz==0)=NaN;
                        
                        for ii=1:4
                            for jj=1:4
                                fname=[dr 'zl' num2str(k-1,'%0.2i') '\' dataname '.zl' num2str(k-1,'%0.2i') '.' num2str(iind(ii),'%0.5i') '.' num2str(jind(jj),'%0.5i') '.nc'];
                                if iex(ii,jj)
                                    ncid = netcdf.open (fname,'NOWRITE');
                                    varid = netcdf.inqVarID(ncid,'depth');
                                    z = netcdf.getVar(ncid,varid);
                                    z=double(z);
                                    z=z';
                                    netcdf.close(ncid);
                                else
                                    z=zeros(ny,nx);
                                    z(z==0)=NaN;
                                end
                                %                        subplot(4,4,ii*jj)
                                %                        surf(double(z));view(2);axis equal;shading flat;colorbar;
                                
                                zz((jj-1)*ny+1:jj*ny,(ii-1)*nx+1:ii*nx)=z;
                                %                                 clf;
                                %                                 surf(double(zz));view(2);axis equal;shading flat;colorbar;hold on;set(gca,'xlim',[0 1200],'ylim',[0 1200]);
                                %                                 drawnow;
                                %                                pause(2)
                            end
                        end
                        %                         if (i-1)*nny+j==13
                        %                             xxxx=1
                        %                         end
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
                            
                            %                             figure(2)
                            %                             clf
                            %                             surf(lon,lat,double(z));view(2);axis equal;shading flat;colorbar;
                            %                             title(num2str(max(max(z))))
                            %                            pause(5)
                            
                            fname=[dr 'zl' num2str(k,'%0.2i') '\' dataname '.zl' num2str(k,'%0.2i') '.' num2str(i,'%0.5i') '.' num2str(j,'%0.5i') '.nc'];

                            OPT.fillValue=-999;

                            nc_grid_createNCfile2(fname,xx,yy,z,OPT);
                            
                        end
                    end
                end
                
            end
            
            % close waitbar
            if ~isempty(hh)
                close(wb);
            end

        end
    end
end

% Check which files are available and make meta file
if imakemeta
    
    for k=1:nrzoom
        nnx=nnxk(k);
        nny=nnyk(k);
        nav=0;
        
        flist2=dir([dr 'zl' num2str(k,'%0.2i') '\*.nc']);
        iin=[];
        jin=[];
        for jjj=1:length(flist2)
            iin(jjj)=str2double(flist2(jjj).name(end-13:end-9));
            jin(jjj)=str2double(flist2(jjj).name(end-7:end-3));
        end
        
        for i=1:nnx
            for j=1:nny
                iava=find(iin==i & jin==j);
                if ~isempty(iava)
                    nav=nav+1;
                    iavailable{k}(nav)=i;
                    javailable{k}(nav)=j;
                end
            end
        end
    end
    fnamemeta=[dr dataname '.nc'];
    nc_createNCmetafile(fnamemeta,x0,y0,dxk,dyk,nnxk,nnyk,nxk,nyk,iavailable,javailable,OPT);
end

