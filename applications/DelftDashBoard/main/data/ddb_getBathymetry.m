function [x,y,z,ok,varargout] = ddb_getBathymetry(bathymetry, xl, yl, varargin)
%DDB_GETBATHYMETRY  loads active bathmetry out DDB
%
%   Syntax:
%   [x y z ok] = ddb_getBathymetry(handles, xl, y#l, varargin)
%
%   Input:
%   handles  =
%   xl       = x1 and x2
%   yl       = y1 and y2
%   varargin = 
%
%   Output:
%   x        = x coordinates of full grid
%   y        = y coordinates of full grid
%   z        = z coordinates of full grid
%   ok       = check
%
%   Example
%   ddb_getBathy
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_getBathymetry.m 18352 2022-09-06 21:14:58Z ormondt $
% $Date: 2022-09-07 05:14:58 +0800 (Wed, 07 Sep 2022) $
% $Author: ormondt $
% $Revision: 18352 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/data/ddb_getBathymetry.m $
% $Keywords: $

%% Initial values
ok              = 0;
zoomlev         = 0;
bathydir        = bathymetry.dir;
bathy           = 'gebco08';
startdate       = ceil(now);
searchinterval  = -1e5;
quiet=0;
justgettiles    = 0; 
cachep          = true;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'zoomlevel'}
                zoomlev=varargin{i+1};
            case{'bathymetry'}
                bathy=varargin{i+1};
            case{'maxcellsize'}
                maxcellsize=varargin{i+1}; % in metres!
            case{'startdate'}
                startdate=varargin{i+1};
            case{'searchinterval'}
                searchinterval=varargin{i+1};
            case{'cachep'}
                if varargin{i+1}==0
                    cachep=false;
                end
            case{'quiet'}
                quiet=1;
        end
    end
end

[x, y, z] = deal([]);

% tic
% disp('Getting bathymetry data ...');

iac       = strmatch(lower(bathy),lower(bathymetry.datasets),'exact');
xsz       = xl(2)-xl(1);

tp        = bathymetry.dataset(iac).type;

switch lower(tp)
    
    %     case{'netcdf'}
    %
    %         url=bathymetry.dataset(iac).URL;
    %
    % %         gridsize=nc_varget(url,'grid_size');
    %         gridsize=loaddap([url '?grid_size']);
    %         gridsize=gridsize.grid_size;
    %
    %         gsmin=(xl(2)-xl(1))/800;
    %
    %         igs=find(gridsize<gsmin,1,'last');
    %         if isempty(igs)
    %             igs=1;
    %         end
    %
    %         lonstr=['lon' num2str(igs)];
    %         latstr=['lat' num2str(igs)];
    %         varstr=['depth' num2str(igs)];
    %
    % %         lon0=nc_varget(url,lonstr);
    % %         lat0=nc_varget(url,latstr);
    %         lon0=loaddap([url '?' lonstr]);
    %         lon0=lon0.(lonstr);
    %         lat0=loaddap([url '?' latstr]);
    %         lat0=lat0.(latstr);
    %
    %         ilon1=find(lon0<=xl(1),1,'last')-1;
    %         if isempty(ilon1)
    %             ilon1=1;
    %         end
    %         ilon1=max(ilon1,1);
    %
    %         ilon2=find(lon0>=xl(2),1)+1;
    %         if isempty(ilon2)
    %             ilon2=length(lon0);
    %         end
    %         ilon2=min(ilon2,length(lon0));
    %
    %         ilat1=find(lat0<=yl(1),1,'last')-1;
    %         if isempty(ilat1)
    %             ilat1=1;
    %         end
    %         ilat1=max(ilat1,1);
    %
    %         ilat2=find(lat0>=yl(2),1)+1;
    %         if isempty(ilat2)
    %             ilat2=length(lat0);
    %         end
    %         ilat2=min(ilat2,length(lat0));
    %
    %         nlon=ilon2-ilon1+1;
    %         nlat=ilat2-ilat1+1;
    %
    % %         z=nc_varget(url,varstr,[ilat1-1 ilon1-1],[nlat nlon]);
    %         z=loaddap([url '?' varstr '[' num2str(ilat1-1) ':1:' num2str(ilat2-1) '][' num2str(ilon1-1) ':1:' num2str(ilon2-1) ']']);
    %         z=z.(varstr).(varstr);
    %
    %         z=double(z);
    %
    %         dlon=(lon0(end)-lon0(1))/(length(lon0)-1);
    %         dlat=(lat0(end)-lat0(1))/(length(lat0)-1);
    %         lon=lon0(1):dlon:lon0(end);
    %         lat=lat0(1):dlat:lat0(end);
    %         lon=lon(ilon1:ilon2);
    %         lat=lat(ilat1:ilat2);
    %
    %         [x,y]=meshgrid(lon,lat);
    %
    %         ok=1;
    
    case{'netcdftiles'}
        
        x=[];
        y=[];
        z=[];
        q=[];
        
        % New tile type
        ok=1;
        
        nLevels=bathymetry.dataset(iac).nrZoomLevels;
        
        for i=1:nLevels
            cellsizex(i)=bathymetry.dataset(iac).zoomLevel(i).dx;
            cellsizey(i)=bathymetry.dataset(iac).zoomLevel(i).dy;
            % Should multiply with unit here...
        end
        
        if zoomlev==0
            % Find zoom level based on resolution
            if strcmpi(bathymetry.dataset(iac).horizontalCoordinateSystem.type,'geographic')
                cellsizex=cellsizex*111111;
            end
            ilev1=find(cellsizex<=maxcellsize,1,'last');
            if isempty(ilev1)
                ilev1=1;
            end
            ilev2=ilev1;
        elseif zoomlev==-1
            % Get all the data from each zoom level !
            justgettiles=1;
            ilev1=1;
            ilev2=nLevels;
        else
            ilev1=zoomlev;
            ilev2=ilev1;
        end
        
        for ilev=ilev1:ilev2
            
            x0=bathymetry.dataset(iac).zoomLevel(ilev).x0;
            y0=bathymetry.dataset(iac).zoomLevel(ilev).y0;
            dx=bathymetry.dataset(iac).zoomLevel(ilev).dx;
            dy=bathymetry.dataset(iac).zoomLevel(ilev).dy;
            nx=bathymetry.dataset(iac).zoomLevel(ilev).nx;
            ny=bathymetry.dataset(iac).zoomLevel(ilev).ny;
            nnx=bathymetry.dataset(iac).zoomLevel(ilev).ntilesx;
            nny=bathymetry.dataset(iac).zoomLevel(ilev).ntilesy;
            vertunits=bathymetry.dataset(iac).verticalCoordinateSystem.units;

            data_in_cell_centres=1;
            if data_in_cell_centres
                x0=x0+0.5*dx; % This really should be added as the data are defined in the cell centres!!!               
                y0=y0+0.5*dy;
            end            
            
            tilesizex=dx*nx;
            tilesizey=dy*ny;
            
            %% Directories and names
            name=bathymetry.dataset(iac).name;
            levdir=['zl' num2str(ilev,'%0.2i')];
            
            iopendap=0;
            ipdrive=0;
            if strcmpi(bathymetry.dataset(iac).URL(1:4),'http')
                % OpenDAP
                iopendap=1;
                remotedir=[bathymetry.dataset(iac).URL '/' levdir '/'];
                localdir=[bathydir name filesep levdir filesep];
            elseif strcmpi(bathymetry.dataset(iac).URL(1),'p') && cachep
                % P drive
                ipdrive=1;
                remotedir=[bathymetry.dataset(iac).URL filesep levdir filesep];
                localdir=[bathydir name filesep levdir filesep];
            else
                % Local
                localdir=[bathymetry.dataset(iac).URL filesep levdir filesep];
                remotedir=localdir;
            end
            
            %% Tiles
            
            xx=x0:tilesizex:x0+(nnx-1)*tilesizex;
            yy=y0:tilesizey:y0+(nny-1)*tilesizey;
            xxend=xx(end)+tilesizex;
            yyend=yy(end)+tilesizey;
            
            % Make sure that tiles are read east +180 deg lon.
            iTileNrs=1:nnx;
            
            if strcmpi(bathymetry.dataset(iac).horizontalCoordinateSystem.type,'geographic') && x0<-179
                % Probably a global dataset
                xx=[xx-360 xx xx+360];
                iTileNrs=[iTileNrs iTileNrs iTileNrs];
            end
            
            % Required tile indices
            if xx(1)>xl(2) || yy(1)>yl(2) || xxend<xl(1) || yyend<yl(1)
                ok=0;
                disp('Tiles are outside of search range');
                return
            end
            
%             data_in_cell_centres=1;
%             if data_in_cell_centres
%                 xx=xx+0.5*dx; % This really should be added as the data are defined in the cell centres!!!               
%                 yy=yy+0.5*dy;
%             end            
            
            ix1=find(xx<xl(1),1,'last');
            if isempty(ix1)
                ix1=1;
            end
            ix2=find(xx>xl(2),1,'first');
            if ~isempty(ix2)
                ix2=max(1,ix2-1);
            else
                ix2=length(xx);
            end
            
            iy1=find(yy<yl(1),1,'last');
            if isempty(iy1)
                iy1=1;
            end
            iy2=find(yy>yl(2),1,'first');
            if ~isempty(iy2)
                iy2=max(1,iy2-1);
            else
                iy2=length(yy);
            end
            
            % Total number of tiles in x and y direction
            nnnx=ix2-ix1+1;
            nnny=iy2-iy1+1;
            
            if ~justgettiles
                % Allocate z
                z=nan(nnny*ny,nnnx*nx);
                q=nan(nnny*ny,nnnx*nx);
            end
            
            iTilesX=iTileNrs(ix1:ix2);
            x0Tiles=xx(ix1:ix2);
            
            if ~justgettiles
                
                % Mesh of horizontal coordinates
                xx=x0Tiles(1):dx:x0Tiles(end) + tilesizex - dx;
                yy=y0+(iy1-1)*tilesizey:dy:y0 + iy2*tilesizey - dy;
                
%                 data_in_cell_centres=1;
%                 if data_in_cell_centres
%                     xx=xx+0.5*dx; % This really should be added as the data are defined in the cell centres!!!               
%                     yy=yy+0.5*dy;
%                 end
%                 
                [x,y]=meshgrid(xx,yy);
            end
            
            % Start indices for each tile in larger matrix
            for i=1:nnnx
                iii1=find(abs(xx-x0Tiles(i))==min(abs(xx-x0Tiles(i))));
                iStartX(i)=iii1(1);
            end
            
            tilen=0;
            ntiles=nnnx*(iy2-iy1+1);
            
            if ~quiet
                wb = awaitbar(0,'Getting tiles ...');
            end
            
            %% Get tiles
            for i=1:nnnx
                
                itile=iTilesX(i);
                
                for j=iy1:iy2
                    
                    tilen=tilen+1;
                    
                    % Waitbar
                    if ~quiet
                        if justgettiles
                            str=['Getting bathymetry level ' num2str(ilev) ' of ' num2str(nLevels) ' - tile ' num2str(tilen) ' of ' ...
                                num2str(ntiles) ' ...'];
                        else
                            str=['Getting bathymetry - tile ' num2str(tilen) ' of ' ...
                                num2str(ntiles) ' ...'];
                        end
                        if verLessThan('matlab', '8.4')
                            [hh,abort2]=awaitbar(tilen/ntiles,wb,str);
                        else
                            [hh,abort2]=awaitbar(tilen/ntiles,get(wb,'Number'),str);
                        end
                        if abort2 % Abort the process by clicking abort button
                            break;
                        end;
                        if isempty(hh); % Break the process when closing the figure
                            break;
                        end;
                    end
                                       
                    zzz=zeros(ny,nx);
                    zzz(zzz==0)=NaN;
                    qqq=[];
                    
                    % First check whether file exists at at all
                    
                    iav=find(bathymetry.dataset(iac).zoomLevel(ilev).iAvailable==itile & bathymetry.dataset(iac).zoomLevel(ilev).jAvailable==j, 1);
                    
                    fv=NaN;
                    
                    if ~isempty(iav)
                        
                        filename=[name '.zl' num2str(ilev,'%0.2i') '.' num2str(itile,'%0.5i') '.' num2str(j,'%0.5i') '.nc'];
                        
                        if iopendap || ipdrive
                            if bathymetry.dataset(iac).useCache
                                % First check if file is available locally
                                idownload=0;
                                if ~exist([localdir filename],'file')
                                    idownload=1;
                                else
                                    f=dir([localdir filename]);
                                    fsize=f.bytes;
                                    if fsize<1000
                                        % Probably something wrong with
                                        % this file. Delete it and download
                                        % again.
                                        idownload=1;
                                        try
                                            delete([localdir filename]);
                                        end
                                    end
                                end
                                if idownload
                                    if ~exist(localdir,'dir')
                                        mkdir(localdir);
                                    end
                                    try
                                        if iopendap
                                            urlwrite([remotedir filename],[localdir filename],'Timeout',5);
                                        else
                                            % pdrive
                                            copyfile([remotedir filename], localdir);
                                        end
                                    catch
                                        disp(['Missing tile : ' remotedir filename]);
                                    end
                                end
                                ncfile=[localdir filename];
                            else
                                ncfile=[remotedir filename];
                            end
                        else
                            ncfile=[localdir filename];
                        end
                        
                        if ~justgettiles
                            zzz=[];
                            qqq=[];
                            fv=[];
                            if exist(ncfile,'file')
                                try
                                    zzz=nc_varget(ncfile, 'depth');
                                    zzz=double(zzz);
                                catch
                                    disp(['Could not read ' ncfile ' !!!']);
                                end
                                try
                                    qqq=nc_varget(ncfile, 'quality');
                                    qqq=double(qqq);
                                end
                                try
                                    fv=nc_attget(ncfile,'depth','fill_value');
                                     ok=1;
                                end
                            end
                        end
                        
                    end
                    
                    if ~justgettiles
                        if ~isempty(zzz)
                            if ~isnan(fv)
                                zzz(zzz==fv)=NaN;
                            end
                            z((j-iy1)*ny+1:(j-iy1+1)*ny,iStartX(i):iStartX(i)+nx-1)=zzz;
                        end
                        if ~isempty(qqq)
                            q((j-iy1)*ny+1:(j-iy1+1)*ny,iStartX(i):iStartX(i)+nx-1)=qqq;
                        end
                    end
                    
                end
            end
            
            % Close waitbar
            if ~quiet
                if ~isempty(hh)
                    close(wb);
                end
            end

            if ~justgettiles
                
                z(z<-15000)=NaN;
                
                %% Crop to requested limits
                
                ix1=find(xx<xl(1),1,'last');
                if isempty(ix1)
                    ix1=1;
                end
                ix2=find(xx>xl(2),1,'first');
                if isempty(ix2)
                    ix2=length(xx);
                end
                
                iy1=find(yy<yl(1),1,'last');
                if isempty(iy1)
                    iy1=1;
                end
                iy2=find(yy>yl(2),1,'first');
                if isempty(iy2)
                    iy2=length(yy);
                end
                
                x=x(iy1:iy2,ix1:ix2);
                y=y(iy1:iy2,ix1:ix2);
                
                
                z=z(iy1:iy2,ix1:ix2);

                q=q(iy1:iy2,ix1:ix2);
                
                % Convert to metres
                switch lower(vertunits)
                    case{'m'}
                    case{'cm'}
                        z=z*0.01;
                    case{'mm'}
                        z=z*0.001;
                    case{'ft'}
                        z=z*0.3048;
                end
                
            end
            
        end
        
        % Deal with quality
        inan=find(~isnan(q), 1);
        if isempty(inan)
            % No quality available
            q=[];
        else
%            z=q;
%            z(q<=2)=NaN;
        end
        
        if ~isempty(q)
            varargout{1}=q;
        end
           
        
    case{'tiles'}
        
        if isempty(bathymetry.dataset(iac).refinementFactor)
            
            if zoomlev==0
                ok=0;
                for i=1:bathymetry.dataset(iac).nrZoomLevels
                    zmmin=bathymetry.dataset(iac).zoomLevel(i).zoomLimits(1);
                    zmmax=bathymetry.dataset(iac).zoomLevel(i).zoomLimits(2);
                    if xsz>=zmmin && xsz<=zmmax
                        iacz=i;
                        ok=1;
                        break;
                    end
                end
                if ok==0
                    return
                end
            else
                ok=1;
                iacz=zoomlev;
            end
            
            tilesize=bathymetry.dataset(iac).zoomLevel(iacz).tileSize;
            gridsize=bathymetry.dataset(iac).zoomLevel(iacz).gridCellSize;
            
            if strcmpi(bathymetry.dataset(iac).horizontalCoordinateSystem.type,'geographic')
                tilesize=dms2degrees(tilesize);
                gridsize=dms2degrees(gridsize);
            end
            
            x0=tilesize*floor(xl(1)/tilesize);
            x1=tilesize*ceil(xl(2)/tilesize);
            y0=tilesize*floor(yl(1)/tilesize);
            y1=tilesize*ceil(yl(2)/tilesize);
            nx=round((x1-x0)/tilesize);
            ny=round((y1-y0)/tilesize);
            
            dirname1=bathymetry.dataset(iac).directoryName;
            dirname2=bathymetry.dataset(iac).zoomLevel(iacz).directoryName;
            fname=bathymetry.dataset(iac).zoomLevel(iacz).fileName;
            
            dirstr=[bathydir '\' dirname1 '\' dirname2 '\'];
            
            z=[];
            for i=1:nx
                zz=[];
                for j=1:ny
                    
                    xsrc=x0+(i-1)*tilesize;
                    ysrc=y0+(j-1)*tilesize;
                    
                    dms=degrees2dms(xsrc);
                    dms=abs(dms);
                    if round(dms(3))==60
                        dms(3)=0;
                        dms(2)=dms(2)+1;
                    end
                    if xsrc<0
                        ewstr='W';
                    else
                        ewstr='E';
                    end
                    xdeg=[ewstr num2str(dms(1),'%0.3i') 'd'];
                    xmin=[num2str(dms(2),'%0.2i') 'm'];
                    xsec=[num2str(round(dms(3)),'%0.2i') 's'];
                    lonstr=[xdeg xmin xsec];
                    
                    dms=degrees2dms(ysrc);
                    dms=abs(dms);
                    if round(dms(3))==60
                        dms(3)=0;
                        dms(2)=dms(2)+1;
                    end
                    
                    if ysrc<0
                        nsstr='S';
                    else
                        nsstr='N';
                    end
                    ydeg=[nsstr num2str(dms(1),'%0.3i') 'd'];
                    ymin=[num2str(dms(2),'%0.2i') 'm'];
                    ysec=[num2str(round(dms(3)),'%0.2i') 's'];
                    latstr=[ydeg ymin ysec];
                    
                    fnametile=[dirstr fname '_' lonstr '_' latstr '.mat'];
                    
                    if exist(fnametile,'file')
                        a=load(fnametile);
                        zzz=a.d.interpz;
                    else
                        zzz=zeros(tilesize/gridsize,tilesize/gridsize);
                        zzz(zzz==0)=NaN;
                    end
                    zz=[zz;zzz];
                end
                z=[z zz];
            end
            
            dx=gridsize;
            dy=dx;
            xx=x0:dx:x0+nx*tilesize-dx;
            yy=y0:dy:y0+ny*tilesize-dy;
            [x,y]=meshgrid(xx,yy);
            
            z(z<-15000)=NaN;
            
        else
            
            % New tile type
            ok=1;
            
            tileMax=bathymetry.dataset(iac).maxTileSize;
            nLevels=bathymetry.dataset(iac).nrZoomLevels;
            nRef=bathymetry.dataset(iac).refinementFactor;
            nCell=bathymetry.dataset(iac).nrCells;
            
            tileSizes(1)=tileMax;
            for i=2:nLevels
                tileSizes(i)=tileSizes(i-1)/nRef;
            end
            cellSizes=tileSizes/nCell;
            
            dx=xl(2)-xl(1);
            
            if zoomlev==0
                ilev=find(tileSizes/dx<0.5,1,'first');
                if isempty(ilev)
                    ilev=bathymetry.dataset(iac).nrZoomLevels;
                end
            else
                ilev=zoomlev;
            end
            
            tilesize=tileSizes(ilev);
            gridsize=cellSizes(ilev);
            
            x0=tilesize*floor(xl(1)/tilesize);
            x1=tilesize*ceil(xl(2)/tilesize);
            y0=tilesize*floor(yl(1)/tilesize);
            y1=tilesize*ceil(yl(2)/tilesize);
            nx=round((x1-x0)/tilesize);
            ny=round((y1-y0)/tilesize);
            
            dirname1=bathymetry.dataset(iac).directoryName;
            dirname2=['zoomlevel' num2str(ilev,'%0.2i')];
            fname=[bathymetry.dataset(iac).directoryName '.z' num2str(ilev,'%0.2i')];
            
            dirstr=[bathydir '\' dirname1 '\' dirname2 '\'];
            
            z=[];
            for i=1:nx
                zz=[];
                for j=1:ny
                    iindex=i+floor((xl(1)-bathymetry.dataset(iac).xOrigin)/tilesize);
                    jindex=j+floor((yl(1)-bathymetry.dataset(iac).yOrigin)/tilesize);
                    fnametile=[dirstr fname '.' num2str(iindex,'%0.6i') '.' num2str(jindex,'%0.6i') '.mat'];
                    if exist(fnametile,'file')
                        a=load(fnametile);
                        zzz=double(a.d.interpz);
                        ok=1;
                    else
                        zzz=zeros(tilesize/gridsize,tilesize/gridsize);
                        zzz(zzz==0)=NaN;
                    end
                    zz=[zz;zzz];
                end
                z=[z zz];
            end
            
            dx=gridsize;
            dy=dx;
            xx=x0:dx:x0+nx*tilesize-dx;
            yy=y0:dy:y0+ny*tilesize-dy;
            [x,y]=meshgrid(xx,yy);
            
            z(z<-15000)=NaN;
            
            
        end
        
    case{'gridded'}
        try
            [x,y]=meshgrid(bathymetry.dataset(iac).x, bathymetry.dataset(iac).y);
            z=bathymetry.dataset(iac).z;
            ok=1;
        catch
            ok=0;
        end
        
    case{'kaartblad'}
        % retreive data from specified dataset with grid_orth_getDataInPolygon
        [x, y, z]   = grid_orth_getDataInPolygon(...
            'dataset'       , bathymetry.dataset(iac).URL, ...
            'polygon'       , [xl(1) xl(2) xl(2) xl(1) xl(1);yl(1) yl(1) yl(2) yl(2) yl(1)]', ...
            'starttime'     , startdate, ...
            'searchinterval', searchinterval, ...
            'plotresult'    , 0, ...
            'plotoverview'  , 0, ...
            'datathinning'  , 1);
        ok=1;

end

% toc

