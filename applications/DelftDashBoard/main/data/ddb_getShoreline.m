function [x y] = ddb_getShoreline(handles, xl, yl, ires)
%DDB_GETSHORELINE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [x y] = ddb_getShoreline(handles, xl, yl, ires)
%
%   Input:
%   handles =
%   xl      =
%   yl      =
%   ires    =
%
%   Output:
%   x       =
%   y       =
%
%   Example
%   ddb_getShoreline
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

% $Id: ddb_getShoreline.m 7795 2012-12-06 13:42:42Z boer_we $
% $Date: 2012-12-06 21:42:42 +0800 (Thu, 06 Dec 2012) $
% $Author: boer_we $
% $Revision: 7795 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/data/ddb_getShoreline.m $
% $Keywords: $

%%
iac=strmatch(lower(handles.screenParameters.shoreline),lower(handles.shorelines.names),'exact');
ldb=handles.shorelines.shoreline(iac);

name=ldb.name;

switch lower(ldb.type)
    case{'netcdftiles'}
        
        zoomstr=ldb.zoomLevel(ires).zoomString;
        
        x0=ldb.zoomLevel(ires).x0;
        y0=ldb.zoomLevel(ires).y0;
        ntilesx=ldb.zoomLevel(ires).ntilesx;
        ntilesy=ldb.zoomLevel(ires).ntilesy;
        dx=ldb.zoomLevel(ires).dx;
        dy=ldb.zoomLevel(ires).dy;
        
        iopendap=0;
        if strcmpi(ldb.URL(1:4),'http')
            % OpenDAP
            iopendap=1;
            remotedir=[ldb.URL '/' zoomstr '/'];
            localdir=[handles.shorelineDir name '\' zoomstr '\'];
        else
            % Local
            localdir=[ldb.URL '\' zoomstr '\'];
            remotedir=localdir;
        end
        
        xx=x0:dx:x0+(ntilesx-1)*dx;
        yy=y0:dy:y0+(ntilesy-1)*dy;
        
        
        % Make sure that tiles are read east +180 deg lon.
        iTileNrs=1:ntilesx;
        
        xAddTiles=zeros(1,ntilesx);
        
        if strcmpi(ldb.horizontalCoordinateSystem.type,'geographic') && x0==-180
            xx=[xx-360 xx xx+360];
            xAddTiles=[xAddTiles-360 xAddTiles xAddTiles+360];
            iTileNrs=[iTileNrs iTileNrs iTileNrs];
        end
        
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
        
        nnnx=ix2-ix1+1;
        nnny=iy2-iy1+1;
        
        iTilesX=iTileNrs(ix1:ix2);
        xAddTiles=xAddTiles(ix1:ix2);
        %         x0Tiles=xx(ix1:ix2);
        
        %         % Start indices for each tile in larger matrix
        %         for i=1:nnnx
        %             iStartX(i)=find(abs(xx-x0Tiles(i))<1e-6);
        %         end
        
        x=[];
        y=[];
        for i=1:nnnx
            
            itile=iTilesX(i);
            xAdd=xAddTiles(i);
            
            for j=iy1:iy2
                
                iav=find(ldb.zoomLevel(ires).iAvailable==itile & ldb.zoomLevel(ires).jAvailable==j, 1);
                
                if ~isempty(iav)
                    
                    filename=[name '.' zoomstr '.' num2str(itile,'%0.5i') '.' num2str(j,'%0.5i') '.nc'];
                    
                    if iopendap
                        if ldb.useCache
                            % First check if file is available locally
                            if ~exist([localdir filename],'file')
                                if ~exist(localdir,'dir')
                                    mkdir(localdir);
                                end
                                try
                                    urlwrite([remotedir filename],[localdir filename]);
                                end
                            end
                            ncfile=[localdir filename];
                        else
                            ncfile=[remotedir filename];
                        end
                    else
                        ncfile=[localdir filename];
                    end
                    
                    if iopendap && ~ldb.useCache
                        try
                            xy=nc_varget(ncfile,'xy');
                            x=[x xy(1,:)+xAdd NaN];
                            y=[y xy(2,:) NaN];
                        end
                    else
                        if exist(ncfile,'file')
                            xy=nc_varget(ncfile,'xy');
                            x=[x xy(1,:)+xAdd NaN];
                            y=[y xy(2,:) NaN];
                        end
                    end
                end
                
            end
        end
        x=double(x);
        y=double(y);
end

